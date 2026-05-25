---
id: INSECURE-DESERIALIZATION
severity_max: HIGH
applies_to: go
---

# Insecure Deserialization (Go)

## Intent

Go không có "magic method RCE" như PHP/Python pickle, nhưng vẫn có những sink nguy hiểm khi deserialize **data từ L1 (request body, file upload, cookie)**:

- `encoding/gob.NewDecoder().Decode()` — cho phép tạo bất kỳ struct nào registered. Nếu attacker control nguồn → có thể trigger `init()`-style side effects qua type assertions, hoặc tạo struct gây panic / DoS.
- `gopkg.in/yaml.v2 / v3` — historical CVE (yaml.v2 < 2.2.4 có DoS qua billion laughs / deeply nested). `Unmarshal` interface{} là vector ưa thích.
- `encoding/json.Unmarshal` vào `interface{}` rồi type assert — không phải RCE nhưng dễ panic / logic bypass.
- Custom binary protocol decode (msgpack, protobuf vào interface{}) — rủi ro tương tự gob.

## Khi nào HIGH

- `gob.NewDecoder(req.Body).Decode(&x)` nơi `x` là `interface{}` hoặc struct chứa `interface{}`
- `yaml.Unmarshal(userBytes, &cfg)` với userBytes từ request hoặc file upload, dùng yaml.v2 cũ
- `json.Unmarshal(body, &map[string]interface{}{})` rồi access field qua type assertion không check ok pattern → panic-able

## Khi nào MEDIUM (giảm cấp)

- Decode vào struct cụ thể (`type Req struct {...}`) với field cố định — Go ép schema, attacker chỉ control giá trị, không tạo type mới
- yaml.v3 (≥ 3.0.0) đã fix billion laughs
- Có size limit (`http.MaxBytesReader`) trước decode

## Cách reasoning (KHÔNG pattern-match thuần)

1. **Grep** sinks: `gob.NewDecoder`, `yaml.Unmarshal`, `yaml.NewDecoder`, `json.NewDecoder`, `msgpack.Unmarshal`, `proto.Unmarshal`
2. **Read** call site: target type là struct cụ thể hay `interface{}`?
3. **Trace L1**:
   - `r.Body`, `c.Request.Body` (gin), `c.BodyParser` (fiber), `multipart.File` (upload) → L1
   - File từ disk được upload trước đó → L1 dù gián tiếp
   - File từ embedded FS / config local → L3, safe
4. **Verify**: có `io.LimitReader` / `http.MaxBytesReader` bao quanh không? Có catch panic không?
5. Check **dependency version**: `go.mod` có yaml.v2 < 2.2.4 → HIGH.

## Search patterns (Go-specific)

```
# encoding/gob
gob\.NewDecoder\s*\(
\.Decode\s*\(\s*&?\s*\w+\s*\)

# yaml
yaml\.Unmarshal\s*\(
yaml\.NewDecoder\s*\(
gopkg\.in/yaml\.v2                    # check go.mod

# json into interface{}
json\.Unmarshal\s*\([^,]+,\s*&\w*[Mm]ap\w*\)
json\.Unmarshal\s*\([^,]+,\s*&interface\{\}
json\.NewDecoder\s*\(.+\)\.Decode\s*\(\s*&\w*interface

# msgpack / proto / cbor
msgpack\.Unmarshal\s*\(
proto\.Unmarshal\s*\(
cbor\.Unmarshal\s*\(
```

## Examples

### HIGH — flag

```go
// gob từ request body — attacker control type
func handler(w http.ResponseWriter, r *http.Request) {
    var payload interface{}
    gob.NewDecoder(r.Body).Decode(&payload)  // BAD: interface{} + L1
}
```

```go
// yaml.v2 cũ + L1
import "gopkg.in/yaml.v2"  // check go.mod version
func upload(c *gin.Context) {
    file, _ := c.FormFile("config")
    f, _ := file.Open()
    data, _ := io.ReadAll(f)
    var cfg map[string]interface{}
    yaml.Unmarshal(data, &cfg)  // BAD: yaml.v2 + interface{} map
}
```

```go
// json interface{} + type assertion không check
var m map[string]interface{}
json.NewDecoder(r.Body).Decode(&m)
name := m["name"].(string)  // panic nếu attacker gửi name là số → DoS
```

### NOT critical — safer

```go
// Struct cụ thể — Go ép schema
type CreateUserReq struct {
    Name  string `json:"name"`
    Email string `json:"email"`
}
var req CreateUserReq
if err := json.NewDecoder(http.MaxBytesReader(w, r.Body, 1<<20)).Decode(&req); err != nil {
    http.Error(w, "bad", 400)
    return
}
// req fields chỉ là string, attacker không tạo type mới được
```

```go
// yaml.v3 + size limit
import "gopkg.in/yaml.v3"
data, _ := io.ReadAll(io.LimitReader(r.Body, 64<<10))
var cfg Config  // struct cụ thể
yaml.Unmarshal(data, &cfg)  // OK
```

## Fix recommendation

1. **Tránh `gob` với input từ L1.** Gob được thiết kế cho IPC giữa Go service tin cậy, KHÔNG cho input untrusted.
2. **Decode vào struct cụ thể**, không dùng `interface{}` / `map[string]interface{}` trừ khi thực sự cần (vd: webhook generic).
3. **Upgrade yaml.v2 → yaml.v3** (`go get gopkg.in/yaml.v3`). Update import.
4. **Wrap input với `http.MaxBytesReader` hoặc `io.LimitReader`** để chống DoS.
5. **Recover panic** trong handler (middleware `recover.New()` của fiber, hoặc tự viết) — nhưng đây chỉ là band-aid, sửa gốc bằng type assertion `v, ok := x.(string)`.
6. **Không decode vào unexported field** từ untrusted source.

## Cross-references

- Rule `20-outdated-dependency`: check go.mod cho `yaml.v2 < 2.2.4`, `protobuf < 1.3.2` (CVE)
- Rule `17-verbose-error-debug-mode`: panic stack trace leak qua response nếu chưa recover
- Rule `07-mass-assignment`: cùng họ "decode L1 vào struct" nhưng nhắm field-level (Role, IsAdmin)
