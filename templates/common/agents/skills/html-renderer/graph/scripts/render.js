const fs = require('fs');
const path = require('path');
const http = require('http');

// Get command line arguments: node render.js <project_path> [output_file] [--watch]
const args = process.argv.slice(2);
const hasWatchFlag = args.includes('--watch');
const cleanArgs = args.filter(arg => arg !== '--watch');

if (cleanArgs.length < 1) {
    console.error('Error: Missing project path parameter!');
    console.log('Usage: node render.js <project_path> [output_file] [--watch]');
    console.log('If output_file is omitted, it defaults to <project_path>/.beads/graph/graph.html');
    process.exit(1);
}

const projectPath = path.resolve(cleanArgs[0]);
const graphDir = path.join(projectPath, '.beads', 'graph');

// Verify graph directory existence
if (!fs.existsSync(graphDir)) {
    console.error(`Error: Graph data directory does not exist at: ${graphDir}`);
    console.error(`Please run '/para-graph' or equivalent command on the project first.`);
    process.exit(1);
}

const outputFile = cleanArgs[1] ? path.resolve(cleanArgs[1]) : path.join(graphDir, 'graph.html');

// Viewer template path verification
const templatePath = path.join(__dirname, '..', 'references', 'viewer-template.html');
if (!fs.existsSync(templatePath)) {
    console.error(`Error: Viewer template does not exist at: ${templatePath}`);
    process.exit(1);
}

const templateContent = fs.readFileSync(templatePath, 'utf8');

// Detect workspace language from .para-workspace.yml
let workspaceLang = 'en'; // default fallback
let workspaceConfigPath = path.join(process.cwd(), '.para-workspace.yml');

if (!fs.existsSync(workspaceConfigPath)) {
    let currentDir = projectPath;
    const rootDir = path.parse(currentDir).root;
    while (currentDir && currentDir !== rootDir) {
        const checkPath = path.join(currentDir, '.para-workspace.yml');
        if (fs.existsSync(checkPath)) {
            workspaceConfigPath = checkPath;
            break;
        }
        currentDir = path.dirname(currentDir);
    }
}

if (fs.existsSync(workspaceConfigPath)) {
    try {
        const configText = fs.readFileSync(workspaceConfigPath, 'utf8');
        const langMatch = configText.match(/^language:[ \t]*["']?([a-z]{2})["']?/m);
        if (langMatch) {
            workspaceLang = langMatch[1];
        } else {
            // Check for nested keys under language line-by-line
            const lines = configText.split(/\r?\n/);
            let inLanguageSection = false;
            let docsVal = '';
            let chatVal = '';
            let thinkingVal = '';
            
            for (const line of lines) {
                if (line.match(/^language:[ \t]*$/)) {
                    inLanguageSection = true;
                    continue;
                }
                if (inLanguageSection) {
                    if (line.trim() && !line.startsWith(' ') && !line.startsWith('\t') && !line.startsWith('#')) {
                        inLanguageSection = false;
                        continue;
                    }
                    const docsMatch = line.match(/^\s*docs:\s*["']?([^"'\r\n]+)["']?/);
                    if (docsMatch) docsVal = docsMatch[1];
                    const chatMatch = line.match(/^\s*chat:\s*["']?([^"'\r\n]+)["']?/);
                    if (chatMatch) chatVal = chatMatch[1];
                    const thinkingMatch = line.match(/^\s*thinking:\s*["']?([^"'\r\n]+)["']?/);
                    if (thinkingMatch) thinkingVal = thinkingMatch[1];
                }
            }
            if (docsVal.includes('vi') || chatVal.includes('vi') || thinkingVal.includes('vi')) {
                workspaceLang = 'vi';
            } else if (docsVal.includes('en') || chatVal.includes('en') || thinkingVal.includes('en')) {
                workspaceLang = 'en';
            }
        }
    } catch (e) {
        // fallback to default language if parse fails
    }
}

// Multi-language dictionary translations for UI elements
const translations = {
    vi: {
        codeGraph: "Đồ thị Mã nguồn",
        nodesLabel: "Cấu phần",
        edgesLabel: "Liên kết",
        enrichedLabel: "Mô tả AI",
        themeBtn: "Đổi Giao diện",
        searchNodes: "Tìm kiếm Cấu phần",
        searchPlaceholder: "Nhập tên cấu phần...",
        filterTypes: "Lọc theo Loại",
        files: "Tập tin",
        functions: "Hàm",
        classes: "Lớp (Class)",
        interfaces: "Giao diện (Interface)",
        variables: "Biến (Variable)",
        connections: "Liên kết",
        minDegree: "Bậc kết nối tối thiểu (Degree)",
        highConfidence: "Chỉ hiện kết nối tin cậy (Extracted)",
        specialFilters: "Bộ lọc đặc biệt",
        noAnchors: "Chưa có neo tài liệu",
        noOwner: "Chưa có người phụ trách",
        batchActions: "Thao tác hàng loạt",
        copyPrompt: "Sao chép Prompt AI",
        copyMarkdown: "Sao chép Markdown List",
        copyJson: "Sao chép JSON",
        select5: "Chọn 5",
        select10: "Chọn 10",
        selectAll: "Chọn tất cả",
        deselectAll: "Bỏ chọn",
        details: "Chi tiết",
        memory: "Nhật ký phiên",
        detailsEmpty: "Chọn một cấu phần trên đồ thị hoặc danh sách để xem chi tiết code.",
        codeLocation: "Vị trí Code",
        openVscode: "Mở trong VSCode",
        signature: "Chữ ký code (Signature)",
        aiSummary: "Tóm tắt ngữ nghĩa AI",
        domainConcepts: "Khái niệm Nghiệp vụ",
        memoryEmpty: "Chưa ghi nhận nhật ký làm việc cho dự án này.",
        sessionLogTimeline: "Dòng thời gian phiên làm việc",
        changeRisk: "Mức độ rủi ro thay đổi",
        riskLow: "Thấp",
        riskMedium: "Trung bình",
        riskHigh: "Cao",
        impactAnalysis: "Phân tích ảnh hưởng thay đổi",
        upstreamImpact: "Ảnh hưởng Ngược (Upstream)",
        downstreamImpact: "Ảnh hưởng Xuôi (Downstream)",
        impactDepth: "cấp",
        noImpact: "Không có tác động lan truyền ngoài cấu phần này.",
        featuresGuideTitle: "HƯỚNG DẪN TÍNH NĂNG",
        featuresGuide1Title: "Khám phá cấu phần",
        featuresGuide1Desc: "Click vào một cấu phần bất kỳ trên biểu đồ để định vị mã nguồn và xem đặc tả chữ ký (signature).",
        featuresGuide2Title: "Phân tích tác động thay đổi",
        featuresGuide2Desc: "Xem ngay các luồng ảnh hưởng dây chuyền (Upstream - Đỏ) và thư viện phụ thuộc (Downstream - Xanh).",
        featuresGuide3Title: "Tóm tắt ngữ nghĩa AI",
        featuresGuide3Desc: "Đọc tóm tắt chức năng bằng ngôn ngữ tự nhiên và danh mục các khái niệm nghiệp vụ liên quan."
    },
    en: {
        codeGraph: "Code Graph",
        nodesLabel: "Nodes",
        edgesLabel: "Edges",
        enrichedLabel: "Enriched",
        themeBtn: "Toggle Light/Dark Theme",
        searchNodes: "Search Nodes",
        searchPlaceholder: "Type node name...",
        filterTypes: "Filter Types",
        files: "Files",
        functions: "Functions",
        classes: "Classes",
        interfaces: "Interfaces",
        variables: "Variables",
        connections: "Connections",
        minDegree: "Minimum Degree (Connections)",
        highConfidence: "High Confidence Only (Extracted)",
        specialFilters: "Special Filters",
        noAnchors: "No document anchors",
        noOwner: "Unassigned owner",
        batchActions: "Batch Actions",
        copyPrompt: "Copy AI Prompt",
        copyMarkdown: "Copy Markdown List",
        copyJson: "Copy JSON",
        select5: "Select 5",
        select10: "Select 10",
        selectAll: "Select All",
        deselectAll: "DeselectAll",
        details: "Details",
        memory: "Memory",
        detailsEmpty: "Select a node in the graph or sidebar to view code details.",
        codeLocation: "Code Location",
        openVscode: "Open in VSCode",
        signature: "Signature",
        aiSummary: "AI Semantic Summary",
        domainConcepts: "Domain Concepts",
        memoryEmpty: "No memory events logged for this project.",
        sessionLogTimeline: "Session Log Timeline",
        changeRisk: "Change Risk Level",
        riskLow: "Low",
        riskMedium: "Medium",
        riskHigh: "High",
        impactAnalysis: "Impact Analysis",
        upstreamImpact: "Upstream Impact (Affected)",
        downstreamImpact: "Downstream Impact (Depends On)",
        impactDepth: "level",
        noImpact: "No ripple impact detected outside this node.",
        featuresGuideTitle: "FEATURES GUIDE",
        featuresGuide1Title: "Component Discovery",
        featuresGuide1Desc: "Click any node on the graph to locate source code and view its signature details.",
        featuresGuide2Title: "Change Impact Analysis",
        featuresGuide2Desc: "Track upstream ripple effects (affected components in red) and downstream dependencies (in blue).",
        featuresGuide3Title: "AI Semantic Enrichment",
        featuresGuide3Desc: "Read natural language function summaries and discover mapped business domain concepts."
    }
};

// Helper to read and parse JSONL files safely
function readJsonl(filePath) {
    if (!fs.existsSync(filePath)) {
        return [];
    }
    try {
        const content = fs.readFileSync(filePath, 'utf8');
        return content.split('\n')
            .map(line => line.trim())
            .filter(line => line.length > 0)
            .map((line, idx) => {
                try {
                    return JSON.parse(line);
                } catch (e) {
                    console.warn(`Warning: Failed to parse JSON line ${idx + 1} in ${path.basename(filePath)}: ${e.message}`);
                    return null;
                }
            })
            .filter(item => item !== null);
    } catch (e) {
        console.error(`Error reading JSONL file ${filePath}:`, e.message);
        return [];
    }
}

// Compile function
function renderGraph(projPath, outputFilePath, template) {
    const projectName = path.basename(projPath);
    
    // Read JSONL data sources
    const entities = readJsonl(path.join(graphDir, 'entities.jsonl'));
    const relations = readJsonl(path.join(graphDir, 'relations.jsonl'));
    const memoryEvents = readJsonl(path.join(graphDir, 'memory-events.jsonl'));
    const memorySlices = readJsonl(path.join(graphDir, 'memory-slices.jsonl'));
    
    // Read stats metadata if exists
    let metadata = { version: "1.0", nodeCount: entities.length, edgeCount: relations.length, enrichedCount: 0 };
    const metadataPath = path.join(graphDir, 'metadata.json');
    if (fs.existsSync(metadataPath)) {
        try {
            metadata = JSON.parse(fs.readFileSync(metadataPath, 'utf8'));
        } catch (e) {
            // fallback to default stats if parse fails
        }
    }

    // Map relations to link format required by force-graph
    const links = relations.map(r => ({
        source: r.sourceId,
        target: r.targetId,
        relation: r.relation,
        confidence: r.confidence || 'EXTRACTED'
    }));

    // Inject data and translation markers into HTML template
    let html = template;
    
    // Set Language and Apply Translations
    html = html.replace('/* LANGUAGE_PLACEHOLDER */', workspaceLang);
    const currentTranslations = translations[workspaceLang] || translations['en'];
    for (const key in currentTranslations) {
        html = html.replaceAll(`/* TRANSLATE:${key} */`, currentTranslations[key]);
    }

    // Replace structural properties
    html = html.replace(/\/\* PROJECT_NAME_PLACEHOLDER \*\//g, projectName);
    html = html.replace(/\/\* PROJECT_ROOT_PLACEHOLDER \*\//g, projPath.replace(/\\/g, '/'));
    html = html.replace(/\/\* DATA_METADATA_JSON_START \*\/[\s\S]*?\/\* DATA_METADATA_JSON_END \*\//, JSON.stringify(metadata, null, 2));
    html = html.replace(/\/\* DATA_GRAPH_JSON_START \*\/[\s\S]*?\/\* DATA_GRAPH_JSON_END \*\//, JSON.stringify({ nodes: entities, links }, null, 2));
    html = html.replace(/\/\* DATA_MEMORY_EVENTS_JSON_START \*\/[\s\S]*?\/\* DATA_MEMORY_EVENTS_JSON_END \*\//, JSON.stringify(memoryEvents, null, 2));
    html = html.replace(/\/\* DATA_MEMORY_SLICES_JSON_START \*\/[\s\S]*?\/\* DATA_MEMORY_SLICES_JSON_END \*\//, JSON.stringify(memorySlices, null, 2));

    // Ensure output parent directory exists
    const parentDir = path.dirname(outputFilePath);
    if (!fs.existsSync(parentDir)) {
        fs.mkdirSync(parentDir, { recursive: true });
    }

    fs.writeFileSync(outputFilePath, html, 'utf8');
    console.log(`✅ Code Graph compiled successfully for project: ${projectName} [Language: ${workspaceLang}]`);
    console.log(`   Destination HTML: ${outputFilePath}`);
}

// Initial compile execution
try {
    renderGraph(projectPath, outputFile, templateContent);
} catch (err) {
    console.error('Fatal compilation error occurred:', err.message);
    process.exit(1);
}

// If --watch flag is set, run file watcher and internal HTTP Server
if (hasWatchFlag) {
    const DEFAULT_PORT = 3001;
    let lastBuildTimestamp = Date.now();
    let rebuildTimeout = null;

    // Trigger rebuild on changes
    function triggerRebuild() {
        try {
            renderGraph(projectPath, outputFile, templateContent);
            lastBuildTimestamp = Date.now();
            console.log('🔄 Watcher: Re-compiled successfully.');
        } catch (e) {
            console.error('❌ Watcher: Re-compile failed:', e.message);
        }
    }

    // List of files to watch in the graph folder
    const filesToWatch = ['entities.jsonl', 'relations.jsonl', 'memory-events.jsonl', 'memory-slices.jsonl', 'metadata.json'];
    
    filesToWatch.forEach(file => {
        const filePath = path.join(graphDir, file);
        if (fs.existsSync(filePath)) {
            fs.watch(filePath, (eventType) => {
                if (eventType === 'change') {
                    // Debounce rebuild to prevent multiple compilations for rapid writes
                    if (rebuildTimeout) clearTimeout(rebuildTimeout);
                    rebuildTimeout = setTimeout(triggerRebuild, 250);
                }
            });
        }
    });

    // Create Watch HTTP Server
    const server = http.createServer((req, res) => {
        // CORS Headers to allow requests from file:// protocols
        res.setHeader('Access-Control-Allow-Origin', '*');
        res.setHeader('Access-Control-Allow-Methods', 'GET, OPTIONS');
        res.setHeader('Access-Control-Allow-Headers', 'Content-Type');
        
        if (req.method === 'OPTIONS') {
            res.writeHead(204);
            res.end();
            return;
        }
        
        // API Endpoint for browser hot-reload polling
        if (req.method === 'GET' && req.url === '/reload-status') {
            res.writeHead(200, { 'Content-Type': 'application/json' });
            res.end(JSON.stringify({ lastBuild: lastBuildTimestamp }));
            return;
        }

        // Serve index compiled HTML directly
        if (req.method === 'GET' && (req.url === '/' || req.url === '/index.html')) {
            if (fs.existsSync(outputFile)) {
                res.writeHead(200, { 'Content-Type': 'text/html; charset=utf-8' });
                res.end(fs.readFileSync(outputFile, 'utf8'));
            } else {
                res.writeHead(404, { 'Content-Type': 'text/plain' });
                res.end('Graph HTML not generated yet. Try triggering a compilation.');
            }
            return;
        }
        
        res.writeHead(404, { 'Content-Type': 'text/plain' });
        res.end('Not Found');
    });

    // Handle port collisions gracefully
    function startServer(port) {
        server.listen(port, () => {
            console.log(`\n📡 Code Graph Watch Server is running at: http://localhost:${port}`);
            console.log(`   Watching data changes in: ${graphDir}\n`);
        }).on('error', (err) => {
            if (err.code === 'EADDRINUSE') {
                console.warn(`Port ${port} is in use, trying port ${port + 1}...`);
                startServer(port + 1);
            } else {
                console.error('Server failed to start:', err.message);
            }
        });
    }

    startServer(DEFAULT_PORT);
}
