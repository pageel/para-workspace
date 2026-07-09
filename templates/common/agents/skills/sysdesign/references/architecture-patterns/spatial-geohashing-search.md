---
tags: [geolocation, spatial, postgis, geohashing, location-based]
stack: [postgres, postgis, redis]
scale: [medium, large]
complexity: advanced
---

# Reference Architecture: Spatial Search & Geohashing (Location-Based Services)

## 1. Topology
*   **API Router**: Handles client queries for nearby points of interest (POI).
*   **Geohash Cache Index**: High-speed lookup index (using Redis Sorted Sets - ZSET) mapping geohash strings to POI IDs.
*   **Primary Spatial Database**: Relational database with spatial index extensions (e.g. PostgreSQL with PostGIS) or document store (MongoDB 2dsphere index).

## 2. API & Communication Spec (Location Query)
*   **Protocols**: REST or GraphQL.
*   **Query Contract**:
    ```typescript
    interface LocationSearchQuery {
      latitude: number;
      longitude: number;
      radius_meters: number;
      limit: number;
    }
    interface POIResponse {
      id: string;
      name: string;
      latitude: number;
      longitude: number;
      distance_meters: number;
    }
    ```

## 3. Database & Storage Architecture (Geohashing & Quadtrees)
*   **Geohashing Principle**: Translates 2D latitude/longitude coordinates into a 1D base32 string representing a geographical bounding box. Points close to each other geographically share prefix strings.
    *   *Precision Guideline*:
        *   Length 5: ~4.9km x 4.9km (neighborhood search)
        *   Length 6: ~1.2km x 0.6km (street/local search)
*   **Quadtree Division**: Recursively subdivides space into 4 quadrants. Highly useful for routing engines to scale search resolution based on POI density (e.g., smaller quadrants in dense cities, larger in rural areas).
*   **Postgres Schema with Spatial Indexes**:
    ```sql
    -- Requires PostGIS extension enabled
    CREATE TABLE points_of_interest (
      id TEXT PRIMARY KEY,
      name TEXT NOT NULL,
      coordinates GEOMETRY(Point, 4326) NOT NULL, -- WGS84 projection
      geohash VARCHAR(12) NOT NULL
    );

    -- Create spatial GiST index for fast bounding box and distance queries
    CREATE INDEX poi_coords_gist ON points_of_interest USING GIST(coordinates);

    -- Create standard B-tree index on geohash for prefix matching
    CREATE INDEX poi_geohash_idx ON points_of_interest(geohash);
    ```

## 4. Software Topology (Search Flow)
*   **Component Architecture**:
    ```mermaid
    graph TD
        Client[Client] --> Router[API Router]
        Router --> GeohashCalc[Compute Geohash of lat/lng]
        Router --> Cache[Redis ZSET Index]
        Cache -- Cache Hit (Nearby POIs) --> Router
        Router -- Cache Miss --> DB[(Postgres + PostGIS)]
        DB --> GiSTQuery[GiST Bounding Box Search]
        GiSTQuery --> Router
    ```
*   **Nearby Search Execution Strategy**:
    1. Calculate the geohash of the client's current coordinates.
    2. Determine the 8 neighboring geohash squares to avoid boundary clipping issues.
    3. Query the index for matching geohash prefixes (e.g. `SELECT * FROM POI WHERE geohash LIKE 'wx4g0%'`).
    4. Calculate actual mathematical distance (Great-Circle Distance or Haversine Formula) to filter exact matches within the target radius.
