const fs = require('fs');
const path = require('path');
const http = require('http');

// Get command line arguments: node render.js <source_md_dir> [target_html_dir] [--watch]
const args = process.argv.slice(2);
const hasWatchFlag = args.includes('--watch');
const cleanArgs = args.filter(arg => arg !== '--watch');

if (cleanArgs.length < 1) {
    console.error('Error: Missing source directory parameter!');
    console.log('Usage: node render.js <source_md_dir> [target_html_dir] [--watch]');
    console.log('If target_html_dir is omitted, it defaults to <source_md_dir>/.html');
    process.exit(1);
}

const sourceDir = path.resolve(cleanArgs[0]);
const outputDir = cleanArgs[1] ? path.resolve(cleanArgs[1]) : path.join(sourceDir, '.html');

// Verify source directory existence
if (!fs.existsSync(sourceDir)) {
    console.error(`Error: Source directory does not exist at: ${sourceDir}`);
    process.exit(1);
}

// Viewer template path verification
const templatePath = path.join(__dirname, '..', 'references', 'viewer-template.html');
if (!fs.existsSync(templatePath)) {
    console.error(`Error: Viewer template does not exist at: ${templatePath}`);
    process.exit(1);
}

const templateContent = fs.readFileSync(templatePath, 'utf8');

// Detect workspace language and kernel version from .para-workspace.yml
let workspaceLang = 'en'; // default fallback
let kernelVersion = '1.8.9'; // default fallback
const workspaceConfigPath = path.join(process.cwd(), '.para-workspace.yml');
if (fs.existsSync(workspaceConfigPath)) {
    try {
        const configText = fs.readFileSync(workspaceConfigPath, 'utf8');
        const langMatch = configText.match(/^language:\s*["']?([a-z]{2})["']?/m);
        if (langMatch) {
            workspaceLang = langMatch[1];
        }
        const kernelMatch = configText.match(/^kernel_version:\s*["']?([0-9.]+)["']?/m);
        if (kernelMatch) {
            kernelVersion = kernelMatch[1];
        }
    } catch (e) {
        console.warn('Warning: Failed to parse .para-workspace.yml, falling back to English.');
    }
}

// Multi-language dictionary translations
const translations = {
    vi: {
        title: "Tài liệu PARA Workspace",
        treeTitle: "Cây thư mục tài liệu",
        tocTitle: "Mục lục trang này",
        sourceLabel: "Nguồn:",
        sourceTitle: "Click để mở trong ứng dụng mặc định hệ thống",
        fontSelectInter: "Font: Inter (Sans)",
        fontSelectOutfit: "Font: Outfit (Modern)",
        fontSelectRoboto: "Font: Roboto",
        fontSelectGeorgia: "Font: Georgia (Serif)",
        chatBtn: "Chat với Agent",
        themeBtn: "Giao diện",
        readmeHomeTitle: "Quay lại README Trang chủ",
        tocToggleTitle: "Ẩn/Hiện Mục lục",
        footerRendered: "Cập nhật lúc:",
        modalTitle: "Yêu cầu Agent Antigravity sửa tài liệu",
        modalTarget: "Mục tiêu:",
        modalPlaceholder: "Nhập yêu cầu điều chỉnh tài liệu của bạn (ví dụ: 'Thêm mô tả cho khóa ngoại DB', 'Viết lại mục 2 rõ hơn'...)",
        modalCancel: "Hủy",
        modalSubmit: "Sao chép yêu cầu",
        inlinePlaceholder: "Nhập yêu cầu sửa... (Nhấn Enter để copy)",
        inlineCopySuccess: "🎉 Đã copy yêu cầu chỉnh sửa vào clipboard!",
        inlineCommentBtn: "Chat",
        inlineCopyBtn: "Sao chép",
        searchPlaceholder: "Tìm kiếm tài liệu...",
        searchBtnLabel: "Tìm kiếm",
        helpBtnTitle: "Glossary & Wiki Trợ giúp (Help)",
        alertCopySuccess: "🎉 Đã copy yêu cầu chỉnh sửa tài liệu vào clipboard!\\n\\n",
        alertServerSuccess: "📬 Watch server của Agent đã nhận yêu cầu ghi đĩa.\\n",
        alertInstructions: "👉 Hãy quay lại khung chat và dán (Ctrl+V) để Agent xử lý ngay.",
        alertError: "Đã xảy ra lỗi khi render tài liệu",
        alertManualCopy: "Hãy copy tay yêu cầu này để dán cho Agent nếu clipboard bị chặn",
        calloutNote: "Ghi chú:",
        calloutTip: "Gợi ý:",
        calloutImportant: "Quan trọng:",
        calloutWarning: "Cảnh báo:",
        calloutCaution: "Lưu ý nguy hiểm:",
        // Quality Dashboard translations
        dashboardTitle: "Bảng điều khiển Chất lượng Tài liệu",
        dashboardSubtitle: "Đo lường độ bao phủ tài liệu kỹ thuật dựa trên phân tích trọng số Đồ thị Mã nguồn.",
        scoreCardTitle: "Điểm Sức khỏe Tài liệu",
        scoreLabel: "Điểm số",
        totalDocs: "Tổng số tài liệu",
        graphNodes: "Cấu phần Đồ thị",
        businessGodNodes: "Thành phần Lõi Nghiệp vụ (God Nodes)",
        healthStatus: "Trạng thái Sức khỏe",
        entityTypeDistribution: "Phân bố theo Loại Cấu phần",
        weightDistribution: "Phân loại theo Trọng số Đồ thị",
        legendCompleted: "Đạt chuẩn (Đầy đủ)",
        legendUnlinked: "Chưa liên kết",
        legendUnenriched: "Chưa mô tả AI",
        explorerTitle: "Trình duyệt Đồ thị Mã & Neo tài liệu",
        searchPlaceholderNodes: "Tìm kiếm node theo tên, file...",
        filterAll: "Tất cả",
        filterCritical: "Cốt lõi (Trọng số 5)",
        filterMedium: "Trung bình",
        filterUnlinked: "Chưa gắn link",
        filterUnlinkedDocs: "Chưa neo (Docs ➔ Code)",
        filterUnlinkedCode: "Chưa cmt (Code ➔ Docs)",
        filterUnenriched: "Chưa mô tả AI",
        filterNoOwner: "Chưa gán người phụ trách",
        badgeNoOwner: "Chưa gán người phụ trách",
        batchActions: "Thao tác hàng loạt",
        copyPrompt: "Sao chép Prompt AI",
        copyMarkdown: "Sao chép Markdown List",
        copyJson: "Sao chép JSON",
        select5: "Chọn 5",
        select10: "Chọn 10",
        selectAll: "Chọn tất cả",
        deselectAll: "Bỏ chọn",
        thNodeEntity: "Cấu phần Mã (Entity)",
        thType: "Phân loại",
        thWeightDegree: "Trọng số / Độ kết nối (Degree)",
        thBlastRadius: "Bán kính ảnh hưởng (Blast Radius)",
        thDocLinks: "Liên kết Tài liệu",
        thDocLinksDocs: "Docs ➔ Code (Neo)",
        thDocLinksCode: "Code ➔ Docs (Cmt)",
        thDescription: "Mô tả / Ngữ nghĩa Hệ thống",
        hotspotsTitle: "⚠️ Điểm nóng ưu tiên",
        hotspotsSubtitle: "Thành phần ảnh hưởng lớn cần viết tài liệu",
        badgeStale: "Cần cập nhật",
        badgeLinkedDocs: "Tài liệu",
        badgeUnlinkedDocs: "Chưa neo",
        badgeLinkedCode: "Comment",
        badgeUnlinkedCode: "Chưa cmt",
        calibrationVerifyComments: "Kiểm tra comment neo trong mã nguồn (Code ➔ Docs)",
        calibrationVerifyCommentsDesc: "Yêu cầu có comment <code>// @para-doc [file.md#anchor]</code> trong code để tham chiếu tới tài liệu.",
        langToggleLabel: "English",
        noNodesFound: "Không tìm thấy thành phần mã nào khớp với bộ lọc và tìm kiếm hiện tại.",
        graphStatsUpdated: "Thống kê đồ thị cập nhật lúc:",
        collapseSidebar: "Thu gọn sidebar",
        expandSidebar: "Mở rộng sidebar",
        loadingSearch: "Đang tải dữ liệu tìm kiếm...",
        noSearchResults: "Không tìm thấy kết quả",
        inlineFeedbackChatWithAI: "Chat với AI",
        inlineFeedbackCopy: "Sao chép",
        inlineCommentFormPlaceholder: "Nhập phản hồi sửa code...",
        inlineFeedbackSubmitTitle: "Sao chép prompt",
        calibrationTitle: "Hiệu chỉnh Chỉ số",
        calibrationFolders: "Loại trừ thư mục tài liệu",
        calibrationWeights: "Trọng số thành phần mã",
        calibrationReset: "Đặt lại mặc định",
        calibrationDesc: "Trọng số đại diện cho độ quan trọng tương đối của từng cấu phần mã:<br/>• <b>Cốt lõi:</b> Các cấu phần lõi ảnh hưởng lớn (Cấu phần Siêu kết nối, độ kết nối >= 20).<br/>• <b>Trung bình:</b> Hàm, lớp, tệp tin tiêu chuẩn.<br/>• <b>Bổ trợ:</b> Các biến và hằng số phụ trợ.<br/>Tài liệu hóa phần Cốt lõi đóng góp điểm số cao hơn."
    },
    en: {
        title: "PARA Workspace Docs",
        treeTitle: "Documentation Tree",
        tocTitle: "Table of Contents",
        sourceLabel: "Source:",
        sourceTitle: "Click to open in system default application",
        fontSelectInter: "Font: Inter (Sans)",
        fontSelectOutfit: "Font: Outfit (Modern)",
        fontSelectRoboto: "Font: Roboto",
        fontSelectGeorgia: "Font: Georgia (Serif)",
        chatBtn: "Chat with Agent",
        themeBtn: "Theme",
        readmeHomeTitle: "Back to README Home",
        tocToggleTitle: "Toggle Outline / Table of Contents",
        footerRendered: "Last updated:",
        modalTitle: "Request Antigravity Agent to edit document",
        modalTarget: "Target:",
        modalPlaceholder: "Enter your document adjustment request (e.g., 'Add DB foreign key description', 'Clarify section 2'...)",
        modalCancel: "Cancel",
        modalSubmit: "Copy Request",
        inlinePlaceholder: "Request edit... (Press Enter to copy)",
        inlineCopySuccess: "🎉 Edit request copied to clipboard!",
        inlineCommentBtn: "Chat",
        inlineCopyBtn: "Copy text",
        searchPlaceholder: "Search docs...",
        searchBtnLabel: "Search",
        helpBtnTitle: "Glossary & Help Wiki",
        alertCopySuccess: "🎉 Document edit request copied to clipboard!\\n\\n",
        alertServerSuccess: "📬 Agent watch server received the write request.\\n",
        alertInstructions: "👉 Go back to chat box and Paste (Ctrl+V) to execute.",
        alertError: "Error occurred while rendering document",
        alertManualCopy: "Please copy this request manually to paste if clipboard access is blocked",
        calloutNote: "Note:",
        calloutTip: "Tip:",
        calloutImportant: "Important:",
        calloutWarning: "Warning:",
        calloutCaution: "Caution:",
        // Quality Dashboard translations
        dashboardTitle: "Docs Quality Dashboard",
        dashboardSubtitle: "Measure documentation coverage based on Code-Graph weights.",
        scoreCardTitle: "Docs Health Score",
        scoreLabel: "Score",
        totalDocs: "Total Documents",
        graphNodes: "Graph Nodes",
        businessGodNodes: "Business God Nodes",
        healthStatus: "Health Status",
        entityTypeDistribution: "Entity Type Distribution",
        weightDistribution: "Weight Distribution",
        legendCompleted: "Completed (Full)",
        legendUnlinked: "Unlinked",
        legendUnenriched: "Unenriched",
        explorerTitle: "Code Graph & Doc Anchors Explorer",
        searchPlaceholderNodes: "Search nodes by name, file...",
        filterAll: "All",
        filterCritical: "Critical (Weight 5)",
        filterMedium: "Medium",
        filterUnlinked: "Unlinked",
        filterUnlinkedDocs: "Docs ➔ Code Unlinked",
        filterUnlinkedCode: "Code ➔ Docs Unlinked",
        filterUnenriched: "Unenriched",
        filterNoOwner: "No Owner",
        badgeNoOwner: "No Owner",
        batchActions: "Batch Actions",
        copyPrompt: "Copy AI Prompt",
        copyMarkdown: "Copy Markdown List",
        copyJson: "Copy JSON",
        select5: "Select 5",
        select10: "Select 10",
        selectAll: "Select All",
        deselectAll: "Deselect",
        thNodeEntity: "Node Entity",
        thType: "Type",
        thWeightDegree: "Weight / Degree",
        thBlastRadius: "Blast Radius",
        thDocLinks: "Doc Links (docAnchors)",
        thDocLinksDocs: "Docs ➔ Code (Anchor)",
        thDocLinksCode: "Code ➔ Docs (Comment)",
        thDescription: "Description / System Semantics",
        hotspotsTitle: "⚠️ Priority Hotspots",
        hotspotsSubtitle: "High-impact components lacking docs",
        badgeStale: "Stale / Outdated",
        badgeLinkedDocs: "Docs",
        badgeUnlinkedDocs: "Unanchored",
        badgeLinkedCode: "Comment",
        badgeUnlinkedCode: "Uncmt",
        calibrationVerifyComments: "Verify code comment references (Code ➔ Docs)",
        calibrationVerifyCommentsDesc: "Require <code>// @para-doc [file.md#anchor]</code> comments in code to refer to documentation.",
        langToggleLabel: "Tiếng Việt",
        noNodesFound: "No code entities found matching the current filter and search.",
        graphStatsUpdated: "Graph stats updated at:",
        collapseSidebar: "Collapse sidebar",
        expandSidebar: "Expand sidebar",
        loadingSearch: "Loading search data...",
        noSearchResults: "No results found",
        inlineFeedbackChatWithAI: "Chat with AI",
        inlineFeedbackCopy: "Copy",
        inlineCommentFormPlaceholder: "Enter code edit feedback...",
        inlineFeedbackSubmitTitle: "Copy prompt",
        calibrationTitle: "Calibration Settings",
        calibrationFolders: "Exclude Document Folders",
        calibrationWeights: "Code Entity Weights",
        calibrationReset: "Reset to Defaults",
        calibrationDesc: "Weights represent the relative priority of each individual code entity:<br/>• <b>Critical:</b> High-impact core components (God Nodes, degree >= 20).<br/>• <b>Medium:</b> Standard functions, classes, and source files.<br/>• <b>Low:</b> Auxiliary variables and constants.<br/>Documenting Critical components contributes more to the overall health score."
    }
};

// Stores timestamp of the latest build for browser hot-reloading
let lastBuildTimestamp = Date.now();

// Extract clean display name from Markdown filename (remove .md)
function getMarkdownCleanName(filePath) {
    return path.basename(filePath, '.md');
}

// Recursively construct Folder Tree JSON
function buildTree(dirPath, rootDir) {
    const stats = fs.statSync(dirPath);
    const node = {
        name: path.basename(dirPath),
        path: dirPath,
        isDirectory: stats.isDirectory(),
        title: stats.isDirectory() ? null : getMarkdownCleanName(dirPath)
    };
    
    if (node.isDirectory) {
        const files = fs.readdirSync(dirPath);
        node.children = [];
        for (const file of files) {
            const childPath = path.join(dirPath, file);
            if (childPath === outputDir) continue;
            if (file.startsWith('.') || 
                file === 'node_modules' || 
                file === 'Archive' || 
                file === 'sandbox' || 
                file === 'dist' || 
                file === 'docs-html') continue;
                
            node.children.push(buildTree(childPath, rootDir));
        }
        
        node.children.sort((a, b) => {
            if (a.isDirectory && !b.isDirectory) return -1;
            if (!a.isDirectory && b.isDirectory) return 1;
            return a.name.localeCompare(b.name);
        });
    }
    return node;
}

// Convert Folder Tree JSON into HTML Sidebar navigation list
function treeToHtml(node, currentSourcePath, currentTargetPath, rootDir, rootOutputDir) {
    if (!node.isDirectory) {
        if (path.extname(node.path) !== '.md') return '';
        
        const relativeFromRoot = path.relative(rootDir, node.path);
        const correspondingHtmlPath = path.join(rootOutputDir, relativeFromRoot.replace(/\.md$/, '.html'));
        
        let relativeUrl = path.relative(path.dirname(currentTargetPath), correspondingHtmlPath);
        relativeUrl = relativeUrl.replace(/\\/g, '/');
        
        const isActive = (node.path === currentSourcePath);
        const activeClass = isActive ? 'active' : '';
        const hrefValue = isActive ? '#' : relativeUrl;
        
        const relativeHtmlPathFromRoot = relativeFromRoot.replace(/\.md$/, '.html').replace(/\\/g, '/');
        
        return `
        <li class="tree-item">
            <a href="${hrefValue}" class="menu-link ${activeClass}" data-docpath="${relativeHtmlPathFromRoot}">
                <i data-lucide="file-text"></i> ${node.title}
            </a>
        </li>`;
    }
    
    let childrenHtml = '';
    if (node.children) {
        for (const child of node.children) {
            childrenHtml += treeToHtml(child, currentSourcePath, currentTargetPath, rootDir, rootOutputDir);
        }
    }
    
    if (node.path === rootDir) {
        // Calculate relative URL to dashboard.html from currentTargetPath
        const dashboardHtmlPath = path.join(rootOutputDir, 'dashboard.html');
        let relativeDashboardUrl = path.relative(path.dirname(currentTargetPath), dashboardHtmlPath);
        relativeDashboardUrl = relativeDashboardUrl.replace(/\\/g, '/');
        
        const isDashboardActive = (currentTargetPath.endsWith('dashboard.html'));
        const activeClass = isDashboardActive ? 'active' : '';
        const hrefValue = isDashboardActive ? '#' : relativeDashboardUrl;

        const dashboardSidebarItem = `
        <li class="tree-item" style="margin-bottom: 8px; border-bottom: 1px solid var(--border-color); padding-bottom: 8px;">
            <a href="${hrefValue}" class="menu-link ${activeClass}" id="dashboard-link">
                <i data-lucide="layout-dashboard" style="color: #ea580c;"></i> Dashboard
            </a>
        </li>`;

        return dashboardSidebarItem + childrenHtml;
    }
    
    if (!childrenHtml.trim()) return '';
    
    return `
    <li class="tree-folder">
        <div class="folder-toggle">
            <span class="chevron-icon-container"><i data-lucide="chevron-right"></i></span>
            <i data-lucide="folder"></i> ${node.name}
        </div>
        <ul class="folder-content" style="display: none;">
            ${childrenHtml}
        </ul>
    </li>`;
}

// Render a single Markdown file to HTML using the template
function renderSingleFile(sourceFile, targetFile, treeRoot, rootDir, rootOutputDir, template, graphNodesMap, calculateBlastRadius) {
    try {
        const markdownContent = fs.readFileSync(sourceFile, 'utf8');
        
        // Parse markdown content for @graph-node anchors
        const nodeRegex = /<!--\s*@graph-node:\s*([^\s>]+)\s*-->/g;
        const linkedNodeIds = [];
        let match;
        while ((match = nodeRegex.exec(markdownContent)) !== null) {
            const nodeId = match[1];
            if (!linkedNodeIds.includes(nodeId)) {
                linkedNodeIds.push(nodeId);
            }
        }

        let modifiedMarkdown = markdownContent;
        if (linkedNodeIds.length > 0 && graphNodesMap) {
            const projectDir = path.dirname(rootDir);
            const docNodesTitle = workspaceLang === 'vi' ? 'Các thành phần mã được tham chiếu' : 'Referenced Code Entities';
            const thEntity = workspaceLang === 'vi' ? 'Thành phần mã' : 'Entity';
            const thType = workspaceLang === 'vi' ? 'Phân loại' : 'Type';
            const thLocation = workspaceLang === 'vi' ? 'Vị trí' : 'Location';
            const thBlast = workspaceLang === 'vi' ? 'Bán kính ảnh hưởng (Blast)' : 'Blast Radius';
            const thDesc = workspaceLang === 'vi' ? 'Mô tả' : 'Description';
            
            let nodesListMarkdown = `\n\n---\n\n### <span style="display: flex; align-items: center; gap: 8px;"><i data-lucide="network" style="width: 18px; height: 18px; color: var(--accent-color);"></i> ${docNodesTitle}</span>\n\n`;
            nodesListMarkdown += `| ${thEntity} | ${thType} | ${thLocation} | ${thBlast} | ${thDesc} |\n`;
            nodesListMarkdown += `| :--- | :--- | :--- | :---: | :--- |\n`;
            
            for (const nodeId of linkedNodeIds) {
                const node = graphNodesMap[nodeId];
                if (node) {
                    const type = node.type || 'unknown';
                    const name = node.name || node.id;
                    const filePath = node.filePath || '';
                    const lines = (node.startLine && node.endLine) ? `L${node.startLine}-${node.endLine}` : '';
                    
                    let location = 'unknown';
                    if (filePath) {
                        const absolutePath = path.resolve(projectDir, 'repo', filePath).replace(/\\/g, '/');
                        const linkText = `${filePath}${lines ? ':' + lines : ''}`;
                        location = `[${linkText}](file:///${absolutePath}${lines ? '#L' + node.startLine + '-L' + node.endLine : ''})`;
                    }
                    
                    const blastRadius = calculateBlastRadius ? calculateBlastRadius(node.id) : 0;
                    const description = (node.semantic && node.semantic.summary) || 'No description available.';
                    
                    let iconName = 'code';
                    if (type === 'file') iconName = 'file-code';
                    else if (type === 'class') iconName = 'box';
                    else if (type === 'function') iconName = 'play-circle';
                    else if (type === 'interface') iconName = 'layout';
                    else if (type === 'variable') iconName = 'trello';
                    
                    const iconHtml = `<i data-lucide="${iconName}" style="width: 14px; height: 14px; display: inline-block; vertical-align: middle; margin-right: 4px; color: var(--text-secondary);"></i>`;
                    nodesListMarkdown += `| ${iconHtml} \`${name}\` | \`${type}\` | ${location} | **${blastRadius}** | ${description} |\n`;
                }
            }
            modifiedMarkdown += nodesListMarkdown;
        }

        // Escape special chars to prevent breaking JS template literals
        const escapedMarkdown = modifiedMarkdown
            .replace(/\\/g, '\\\\')
            .replace(/`/g, '\\`')
            .replace(/\${/g, '\\${');
            
        const relativeSourcePath = path.relative(process.cwd(), sourceFile);
        const absoluteSourcePath = path.resolve(sourceFile);
        const docCleanName = getMarkdownCleanName(sourceFile);
        
        const sidebarHtml = ''; // Sub-pages run in App Shell iframe and do not need individual sidebars
        
        const now = new Date();
        const renderTime = now.toLocaleString(workspaceLang === 'vi' ? 'vi-VN' : 'en-US', {
            year: 'numeric',
            month: '2-digit',
            day: '2-digit',
            hour: '2-digit',
            minute: '2-digit',
            second: '2-digit'
        });
        
        // Apply i18n translation replacements
        let html = template;
        html = html.replaceAll('/* WORKSPACE_LANG */', workspaceLang);
        
        const currentTranslations = translations[workspaceLang] || translations['en'];
        for (const key in currentTranslations) {
            html = html.replaceAll(`/* TRANSLATE:${key} */`, currentTranslations[key]);
        }
        
        const relativeReadmeFromTarget = path.relative(path.dirname(targetFile), path.join(rootOutputDir, 'README.html'));
        const relativeReadmeUrl = relativeReadmeFromTarget.replace(/\\/g, '/');
        
        const relativeSearchIndexFromTarget = path.relative(path.dirname(targetFile), path.join(rootOutputDir, 'search-index.js'));
        const relativeSearchIndexUrl = relativeSearchIndexFromTarget.replace(/\\/g, '/');
        
        // Replace structural data placeholders
        html = html
            .replaceAll('/* MARKDOWN_CONTENT_PLACEHOLDER */', escapedMarkdown)
            .replaceAll('/* SOURCE_MD_PATH */', relativeSourcePath)
            .replaceAll('/* SOURCE_MD_ABS_PATH */', absoluteSourcePath)
            .replaceAll('/* CURRENT_DOC_NAME */', docCleanName)
            .replaceAll('/* README_RELATIVE_URL */', relativeReadmeUrl)
            .replaceAll('/* SEARCH_INDEX_RELATIVE_URL */', relativeSearchIndexUrl)
            .replaceAll('/* RENDER_TIME */', renderTime)
            .replaceAll('/* KERNEL_VERSION */', kernelVersion)
            .replaceAll('<!-- DOCS_LIST_PLACEHOLDER -->', sidebarHtml);
            
        const targetDir = path.dirname(targetFile);
        if (!fs.existsSync(targetDir)) {
            fs.mkdirSync(targetDir, { recursive: true });
        }
        
        fs.writeFileSync(targetFile, html, 'utf8');
    } catch (err) {
        console.error(`❌ Compilation error for file ${sourceFile}:`, err.message);
    }
}

// Recursively compile source directory to output directory
function renderDirectory(srcDir, destDir, template) {
    const treeRoot = buildTree(srcDir, srcDir);
    
    const allMdFiles = [];
    function collectMdFiles(node) {
        if (!node.isDirectory) {
            if (path.extname(node.path) === '.md') {
                allMdFiles.push(node.path);
            }
        } else if (node.children) {
            for (const child of node.children) {
                collectMdFiles(child);
            }
        }
    }
    collectMdFiles(treeRoot);
    
    // Load Graph data first to support dynamic node referencing in renderSingleFile
    const projectDir = path.dirname(srcDir);
    const graphDir = path.join(projectDir, '.beads', 'graph');
    const entitiesPath = path.join(graphDir, 'entities.jsonl');
    const relationsPath = path.join(graphDir, 'relations.jsonl');
    
    const outdegrees = {};
    const indegrees = {};
    if (fs.existsSync(relationsPath)) {
        try {
            const relLines = fs.readFileSync(relationsPath, 'utf8').split('\n');
            for (const line of relLines) {
                if (line.trim()) {
                    const rel = JSON.parse(line);
                    if (rel.sourceId) {
                        outdegrees[rel.sourceId] = (outdegrees[rel.sourceId] || 0) + 1;
                    }
                    if (rel.targetId) {
                        indegrees[rel.targetId] = (indegrees[rel.targetId] || 0) + 1;
                    }
                }
            }
        } catch (e) {
            console.warn('Warning: Failed to read or parse graph relations.jsonl:', e.message);
        }
    }
    
    let graphNodes = [];
    let hasGraph = false;
    
    if (fs.existsSync(entitiesPath)) {
        try {
            const lines = fs.readFileSync(entitiesPath, 'utf8').split('\n');
            for (const line of lines) {
                if (line.trim()) {
                    const node = JSON.parse(line);
                    node.indegree = indegrees[node.id] || 0;
                    node.outdegree = outdegrees[node.id] || 0;
                    node.degree = node.indegree + node.outdegree;
                    graphNodes.push(node);
                }
            }
            hasGraph = true;
        } catch (e) {
            console.warn('Warning: Failed to read or parse graph entities.jsonl:', e.message);
        }
    }

    const graphNodesMap = {};
    const impactAdjacencyList = {};
    const blastRadii = {};
    let calculateBlastRadius = null;

    if (hasGraph) {
        for (const node of graphNodes) {
            graphNodesMap[node.id] = node;
        }

        if (fs.existsSync(relationsPath)) {
            try {
                const relLines = fs.readFileSync(relationsPath, 'utf8').split('\n');
                for (const line of relLines) {
                    if (line.trim()) {
                        const rel = JSON.parse(line);
                        if (rel.sourceId && rel.targetId) {
                            if (!impactAdjacencyList[rel.targetId]) {
                                impactAdjacencyList[rel.targetId] = [];
                            }
                            if (!impactAdjacencyList[rel.targetId].includes(rel.sourceId)) {
                                impactAdjacencyList[rel.targetId].push(rel.sourceId);
                            }
                        }
                    }
                }
            } catch (e) {
                console.warn('Warning: Failed to build impact list:', e.message);
            }
        }

        calculateBlastRadius = function(nodeId) {
            if (blastRadii[nodeId] !== undefined) return blastRadii[nodeId];
            
            const visited = new Set();
            const queue = [nodeId];
            visited.add(nodeId);
            
            while (queue.length > 0) {
                const current = queue.shift();
                const dependents = impactAdjacencyList[current] || [];
                for (const dep of dependents) {
                    if (!visited.has(dep)) {
                        visited.add(dep);
                        queue.push(dep);
                    }
                }
            }
            
            const radius = visited.size - 1;
            blastRadii[nodeId] = radius;
            return radius;
        };
    }

    const searchIndex = [];
    for (const sourceFile of allMdFiles) {
        const relativeFromRoot = path.relative(srcDir, sourceFile);
        const targetFile = path.join(destDir, relativeFromRoot.replace(/\.md$/, '.html'));
        renderSingleFile(sourceFile, targetFile, treeRoot, srcDir, destDir, template, graphNodesMap, calculateBlastRadius);
        
        // Collect search index
        try {
            const rawContent = fs.readFileSync(sourceFile, 'utf8');
            const cleanTitle = getMarkdownCleanName(sourceFile);
            
            // Strip markdown formatting & limit length
            let cleanText = rawContent
                .replace(/```[\s\S]*?```/g, ' ') // replace code blocks with space to keep index size optimal
                .replace(/[\#\*\`\[\]\(\)\-\+\!\_\>]/g, ' ') // strip syntax chars
                .replace(/\s+/g, ' ')
                .trim();
                
            if (cleanText.length > 15000) {
                cleanText = cleanText.substring(0, 15000) + '...';
            }
            
            const relHtmlUrl = relativeFromRoot.replace(/\.md$/, '.html').replace(/\\/g, '/');
            searchIndex.push({
                path: relHtmlUrl,
                title: cleanTitle,
                content: cleanText
            });
        } catch (e) {
            console.warn(`Warning: Failed to parse search index for ${sourceFile}`, e.message);
        }
    }
    
    // Calculate Graph Traceability and compile dashboard.html
    let docsWithAnchors = 0;
    for (const mdFile of allMdFiles) {
        try {
            const content = fs.readFileSync(mdFile, 'utf8');
            if (content.includes('<!-- @graph-node:')) {
                docsWithAnchors++;
            }
        } catch (e) {}
    }
    
    let dashboardStats = {
        totalDocs: allMdFiles.length,
        docsWithAnchors: docsWithAnchors,
        totalNodes: graphNodes.length,
        enrichableNodes: 0,
        linkedNodes: 0,
        enrichedNodes: 0,
        totalGodNodes: 0,
        documentedGodNodes: 0,
        weightedHealthScore: 0,
        staleDocsCount: 0
    };
    
    let processedNodesData = [];
    
    if (hasGraph) {

        const enrichableNodes = graphNodes.filter(node => {
            const isTest = node.filePath && (node.filePath.startsWith('tests/') || node.filePath.includes('.test.'));
            return !isTest;
        });
        
        const linkedNodes = enrichableNodes.filter(node => node.semantic && node.semantic.docAnchors && node.semantic.docAnchors.length > 0);
        const enrichedNodes = enrichableNodes.filter(node => node.semantic && node.semantic.summary && node.semantic.summary.trim() !== '');
        
        const godNodes = enrichableNodes.filter(node => node.degree >= 20);
        const documentedGodNodes = godNodes.filter(node => node.semantic && node.semantic.docAnchors && node.semantic.docAnchors.length > 0);
        const staleNodes = enrichableNodes.filter(node => node.staleSince && node.staleSince !== null);
        
        let totalWeight = 0;
        let linkedWeight = 0;
        
        const fileCommentsCache = {};
        function getParaDocCommentsForFile(absolutePath) {
            if (fileCommentsCache[absolutePath]) {
                return fileCommentsCache[absolutePath];
            }
            const comments = [];
            if (fs.existsSync(absolutePath)) {
                try {
                    const content = fs.readFileSync(absolutePath, 'utf8');
                    const lines = content.split('\n');
                    lines.forEach((line, idx) => {
                        const lineNum = idx + 1;
                        const match = line.match(/@para-doc\s+\[([^\]]+)\]/);
                        if (match) {
                            comments.push({
                                line: lineNum,
                                docLink: match[1].trim()
                            });
                        }
                    });
                } catch (e) {
                    console.warn(`Warning: Failed to read file for @para-doc comments: ${absolutePath}`, e.message);
                }
            }
            fileCommentsCache[absolutePath] = comments;
            return comments;
        }

        processedNodesData = enrichableNodes.map(node => {
            let weight = 2; // medium default
            let weightedClass = 'medium';
            
            const isCritical = node.degree >= 20;
            
            if (isCritical) {
                weight = 5;
                weightedClass = 'critical';
            } else if (node.type === 'variable') {
                weight = 0.5;
                weightedClass = 'low';
            }
            
            const isLinked = node.semantic && node.semantic.docAnchors && node.semantic.docAnchors.length > 0;
            const isEnriched = node.semantic && node.semantic.summary && node.semantic.summary.trim() !== '';
            
            // Parse @para-doc comments from source code
            const absoluteFilePath = path.resolve(projectDir, 'repo', node.filePath || '');
            const fileComments = getParaDocCommentsForFile(absoluteFilePath);
            const codeDocs = [];
            fileComments.forEach(comment => {
                if (node.type === 'file') {
                    if (comment.line <= 5) {
                        codeDocs.push(comment.docLink);
                    }
                } else {
                    if (comment.line >= (node.startLine || 1) - 4 && comment.line <= (node.startLine || 1)) {
                        codeDocs.push(comment.docLink);
                    }
                }
            });
            const hasCodeDoc = codeDocs.length > 0;

            totalWeight += weight;
            let completionFactor = 0;
            if (isLinked && hasCodeDoc) {
                completionFactor = 1.0;
            } else if (isLinked || hasCodeDoc) {
                completionFactor = 0.5;
            }
            linkedWeight += weight * completionFactor;
            
            return {
                id: node.id,
                name: node.name,
                type: node.type,
                filePath: node.filePath,
                absoluteFilePath: absoluteFilePath,
                startLine: node.startLine || 1,
                endLine: node.endLine || 1,
                degree: node.degree || 0,
                indegree: node.indegree || 0,
                outdegree: node.outdegree || 0,
                blastRadius: calculateBlastRadius(node.id),
                isStale: node.staleSince !== undefined && node.staleSince !== null,
                weight: weight,
                weightedClass: weightedClass,
                isLinked: isLinked,
                isEnriched: isEnriched,
                docAnchors: (node.semantic && node.semantic.docAnchors) || [],
                codeDocs: codeDocs,
                summary: (node.semantic && node.semantic.summary) || ''
            };
        });
        
        const weightedHealthScore = totalWeight > 0 ? (linkedWeight / totalWeight) * 100 : 0;
        const codeLinkedNodes = enrichableNodes.filter(node => {
            const absPath = path.resolve(projectDir, 'repo', node.filePath || '');
            const fileComments = getParaDocCommentsForFile(absPath);
            if (node.type === 'file') {
                return fileComments.some(c => c.line <= 5);
            } else {
                return fileComments.some(c => c.line >= (node.startLine || 1) - 4 && c.line <= (node.startLine || 1));
            }
        });
        const documentedGodNodesCount = godNodes.filter(node => node.semantic && node.semantic.docAnchors && node.semantic.docAnchors.length > 0).length;
        const codeLinkedGodNodesCount = godNodes.filter(node => {
            const absPath = path.resolve(projectDir, 'repo', node.filePath || '');
            const fileComments = getParaDocCommentsForFile(absPath);
            return fileComments.some(c => c.line >= (node.startLine || 1) - 4 && c.line <= (node.startLine || 1));
        }).length;
        
        dashboardStats.enrichableNodes = enrichableNodes.length;
        dashboardStats.linkedNodes = linkedNodes.length;
        dashboardStats.enrichedNodes = enrichedNodes.length;
        dashboardStats.totalGodNodes = godNodes.length;
        dashboardStats.documentedGodNodes = documentedGodNodesCount;
        dashboardStats.weightedHealthScore = weightedHealthScore;
        dashboardStats.staleDocsCount = staleNodes.length;
        
        // Split stats for storage
        dashboardStats.linkedDocsNodes = linkedNodes.length;
        dashboardStats.linkedCodeNodes = codeLinkedNodes.length;
        dashboardStats.linkedDocsGodNodes = documentedGodNodesCount;
        dashboardStats.linkedCodeGodNodes = codeLinkedGodNodesCount;
        
        // Auto-update README.md with new Graph Traceability stats
        const readmePath = path.join(srcDir, 'README.md');
        if (fs.existsSync(readmePath)) {
            try {
                let readmeContent = fs.readFileSync(readmePath, 'utf8');
                const traceabilityHeader = '## Graph Traceability';
                const updatedDate = new Date().toISOString().split('T')[0];
                
                const docsWithAnchorsPct = Math.round(docsWithAnchors / allMdFiles.length * 100);
                const linkedDocsPct = Math.round(linkedNodes.length / enrichableNodes.length * 100);
                const linkedCodePct = Math.round(codeLinkedNodes.length / enrichableNodes.length * 100);
                const godDocsPct = godNodes.length > 0 ? Math.round(documentedGodNodesCount / godNodes.length * 100) : 0;
                const godCodePct = godNodes.length > 0 ? Math.round(codeLinkedGodNodesCount / godNodes.length * 100) : 0;
                
                const newTraceabilityContent = `## Graph Traceability

> Auto-generated by \`/docs update --graph\` | Last scan: ${updatedDate}

| Metric | Value |
|:--|:--|
| Total docs | ${allMdFiles.length} |
| Docs with graph anchors | ${docsWithAnchors} (${docsWithAnchorsPct}%) |
| Graph nodes with docAnchors (Docs ➔ Code) | ${linkedNodes.length}/${enrichableNodes.length} enrichable (${linkedDocsPct}%) |
| Graph nodes with para-doc (Code ➔ Docs) | ${codeLinkedNodes.length}/${enrichableNodes.length} enrichable (${linkedCodePct}%) |
| God Nodes covered (Docs ➔ Code) | ${documentedGodNodesCount}/${godNodes.length} top-connected (${godDocsPct}%) |
| God Nodes covered (Code ➔ Docs) | ${codeLinkedGodNodesCount}/${godNodes.length} top-connected (${godCodePct}%) |
| Docs Health Score (Weighted Double-Binding) | ${Math.round(weightedHealthScore)}/100 |
| Stale docs (code changed) | ${staleNodes.length} |
`;
                const regex = /## Graph Traceability[\s\S]*/;
                if (readmeContent.match(regex)) {
                    readmeContent = readmeContent.replace(regex, newTraceabilityContent.trim() + '\n');
                } else {
                    readmeContent = readmeContent.trim() + '\n\n' + newTraceabilityContent;
                }
                fs.writeFileSync(readmePath, readmeContent, 'utf8');
                console.log('📝 Automatically updated Graph Traceability stats in README.md');
            } catch (e) {
                console.warn('Warning: Failed to update README.md index statistics:', e.message);
            }
        }
    }
    
    // 3.5. Build Alignment Data for Dashboard
    const alignmentData = {};
    
    function isLooseAnchorMatch(anchor, headersList) {
        if (!anchor) return false;
        
        const removeAccents = (str) => {
            return str.normalize('NFD')
                      .replace(/[\u0300-\u036f]/g, '')
                      .replace(/[đĐ]/g, 'd');
        };
        
        const cleanAnchor = removeAccents(anchor.toLowerCase()).replace(/[^a-z0-9]/g, '');
        if (!cleanAnchor) return false;
        
        return headersList.some(header => {
            const cleanHeader = removeAccents(header.toLowerCase()).replace(/[^a-z0-9]/g, '');
            return cleanHeader.includes(cleanAnchor) || cleanAnchor.includes(cleanHeader);
        });
    }

    for (const mdFile of allMdFiles) {
        const relPath = path.relative(srcDir, mdFile).replace(/\\/g, '/');
        const title = getMarkdownCleanName(mdFile);
        
        let mdContent = '';
        try {
            mdContent = fs.readFileSync(mdFile, 'utf8');
        } catch (e) {
            continue;
        }
        
        const headers = [];
        const headerRegex = /^(#{1,6})\s+(.+)$/gm;
        let hMatch;
        while ((hMatch = headerRegex.exec(mdContent)) !== null) {
            headers.push(hMatch[2].trim());
        }
        
        const docNodes = processedNodesData.filter(node => {
            const matchesDoc = (anchor) => {
                const cleanAnchor = anchor.split('#')[0];
                const anchorBase = path.basename(cleanAnchor).toLowerCase();
                const fileBase = path.basename(mdFile).toLowerCase();
                return anchorBase === fileBase;
            };
            return node.docAnchors.some(matchesDoc) || node.codeDocs.some(matchesDoc);
        });
        
        if (docNodes.length === 0) continue;
        
        // Build Mermaid diagram
        let mermaid = 'graph TD\n';
        const nodeIdsInDoc = new Set(docNodes.map(n => n.id));
        
        docNodes.forEach(n => {
            const cleanId = n.id.replace(/[^a-zA-Z0-9]/g, '_');
            const cleanName = n.name.replace(/["']/g, '');
            mermaid += `    ${cleanId}["${n.type}: ${cleanName}"]\n`;
        });
        
        let hasMermaidRelations = false;
        for (const targetId in impactAdjacencyList) {
            if (nodeIdsInDoc.has(targetId)) {
                impactAdjacencyList[targetId].forEach(sourceId => {
                    if (nodeIdsInDoc.has(sourceId)) {
                        const srcClean = sourceId.replace(/[^a-zA-Z0-9]/g, '_');
                        const tgtClean = targetId.replace(/[^a-zA-Z0-9]/g, '_');
                        mermaid += `    ${srcClean} --> ${tgtClean}\n`;
                        hasMermaidRelations = true;
                    }
                });
            }
        }
        
        // Build Audit Reports
        const auditReports = [];
        
        // Broken links check
        docNodes.forEach(node => {
            const allAnchors = [...node.docAnchors, ...node.codeDocs];
            allAnchors.forEach(anchorStr => {
                if (anchorStr.includes('#')) {
                    const parts = anchorStr.split('#');
                    const anchorFile = parts[0];
                    const anchorName = parts[1];
                    
                    const anchorFileBase = path.basename(anchorFile).toLowerCase();
                    const currentFileBase = path.basename(mdFile).toLowerCase();
                    if (anchorFileBase === currentFileBase) {
                        const isMatch = isLooseAnchorMatch(anchorName, headers);
                        if (!isMatch) {
                            auditReports.push({
                                severity: 'medium',
                                title: workspaceLang === 'vi' ? `Neo liên kết hỏng trong \`${node.name}\`` : `Broken Anchor Link in Node \`${node.name}\``,
                                description: workspaceLang === 'vi' 
                                    ? `Cấu phần liên kết tới neo \`#${anchorName}\` nhưng tiêu đề này không tồn tại trong tài liệu spec.`
                                    : `Node linked to anchor \`#${anchorName}\` but this header was not found in the spec file.`,
                                solution: workspaceLang === 'vi'
                                    ? `Cập nhật lại tiêu đề spec hoặc sửa chú thích neo trong code thành: ${headers.slice(0, 3).map(h => '`#' + h + '`').join(', ')}.`
                                    : `Update the spec header or correct the comment link to valid headers: ${headers.slice(0, 3).map(h => '`#' + h + '`').join(', ')}.`
                            });
                        }
                    }
                }
            });
        });
        
        // Specific payments check for reconciliation
        if (relPath.includes('payment') || relPath.includes('reconcil')) {
            const reconciliationPath = path.resolve(projectDir, 'repo', 'src/lib/reconciliation.ts');
            if (fs.existsSync(reconciliationPath)) {
                try {
                    const codeContent = fs.readFileSync(reconciliationPath, 'utf8');
                    if (codeContent.includes("status: 'paid'") && codeContent.includes("applyRulesToExistingPayments")) {
                        const applyRulesBlock = codeContent.substring(codeContent.indexOf("applyRulesToExistingPayments"));
                        if (applyRulesBlock.includes("status: 'paid'") && !applyRulesBlock.includes("payment.amount >= invoice.amount") && !applyRulesBlock.includes("payment.amount >= matchedInvoice.amount")) {
                            auditReports.push({
                                severity: 'high',
                                title: workspaceLang === 'vi' ? 'GAP: Vi phạm quy tắc Underpayment trong đối soát hàng loạt' : 'GAP: Underpayment violation in batch reconciliation',
                                description: workspaceLang === 'vi'
                                    ? `Trong hàm \`applyRulesToExistingPayments\`, hệ thống tự động gán status đơn hàng thành \`'paid'\` khi đối soát hàng loạt mà không check điều kiện thanh toán thiếu.`
                                    : `In \`applyRulesToExistingPayments\`, the system sets invoice status to \`'paid'\` directly without verifying if the payment amount is sufficient.`,
                                solution: workspaceLang === 'vi'
                                    ? `Sửa logic gán status thành: \`const status = payment.amount >= invoice.amount ? 'paid' : 'partially_paid';\`.`
                                    : `Modify the status assignment logic to check: \`const status = payment.amount >= invoice.amount ? 'paid' : 'partially_paid';\`.`
                            });
                        }
                    }
                    if (!codeContent.includes("sum(payments.amount)") && !codeContent.includes("sum(payment.amount)")) {
                        auditReports.push({
                            severity: 'medium',
                            title: workspaceLang === 'vi' ? 'GAP: Thiếu cơ chế cộng dồn thanh toán bổ sung' : 'GAP: Missing payment union logic',
                            description: workspaceLang === 'vi'
                                ? `Hệ thống chưa có logic cộng dồn tổng tiền các payment để kích hoạt hóa đơn thanh toán thiếu sang paid.`
                                : `The system lacks logic to sum up partial payments to automatically transition underpaid invoices to paid.`,
                            solution: workspaceLang === 'vi'
                                ? `Viết thêm hàm helper \`checkAndUnionPartialPayments(db, invoiceId)\` chạy khi gán payment.`
                                : `Implement helper function \`checkAndUnionPartialPayments(db, invoiceId)\` to check total payment amount.`
                        });
                    }
                } catch (err) {}
            }
        }
        
        // Build Decision Table
        let decisionTable = [];
        if (relPath.includes('payment') || relPath.includes('reconcil')) {
            if (workspaceLang === 'vi') {
                decisionTable = [
                    { "Kịch bản nghiệp vụ": "Thanh toán đủ", "Khớp Dịch vụ?": true, "Y >= X (Đủ tiền)": true, "Trạng thái Invoice": "paid", "Kích hoạt Dịch vụ": true },
                    { "Kịch bản nghiệp vụ": "Thanh toán thiếu", "Khớp Dịch vụ?": true, "Y >= X (Đủ tiền)": false, "Trạng thái Invoice": "partially_paid", "Kích hoạt Dịch vụ": false },
                    { "Kịch bản nghiệp vụ": "Chuyển dư tiền", "Khớp Dịch vụ?": true, "Y >= X (Đủ tiền)": true, "Trạng thái Invoice": "paid (Dư tiền)", "Kích hoạt Dịch vụ": true },
                    { "Kịch bản nghiệp vụ": "Không khớp dịch vụ", "Khớp Dịch vụ?": false, "Y >= X (Đủ tiền)": "N/A", "Trạng thái Invoice": "N/A", "Kích hoạt Dịch vụ": "Gia hạn cơ chế cũ (100k=30d)" }
                ];
            } else {
                decisionTable = [
                    { "Scenario": "Full Payment", "Matched Service": true, "Paid >= Price": true, "Invoice Status": "paid", "Activate Service": true },
                    { "Scenario": "Underpayment", "Matched Service": true, "Paid >= Price": false, "Invoice Status": "partially_paid", "Activate Service": false },
                    { "Scenario": "Overpayment", "Matched Service": true, "Paid >= Price": true, "Invoice Status": "paid (overpaid)", "Activate Service": true },
                    { "Scenario": "No Matched Service", "Matched Service": false, "Paid >= Price": "N/A", "Invoice Status": "N/A", "Activate Service": "Extend by 100k=30d legacy logic" }
                ];
            }
        } else {
            decisionTable = docNodes.slice(0, 3).map(n => {
                return workspaceLang === 'vi' ? {
                    "Cấu phần mã": n.name,
                    "Loại": n.type,
                    "Vị trí": n.filePath + ':' + n.startLine,
                    "Độ kết nối": n.degree,
                    "Đại diện Nghiệp vụ": n.summary ? n.summary.substring(0, 50) + '...' : 'Không có'
                } : {
                    "Code Entity": n.name,
                    "Type": n.type,
                    "Location": n.filePath + ':' + n.startLine,
                    "Degree": n.degree,
                    "Business Meaning": n.summary ? n.summary.substring(0, 50) + '...' : 'None'
                };
            });
        }
        
        alignmentData[relPath] = {
            title: title,
            mermaid: mermaid,
            decisionTable: decisionTable,
            auditReports: auditReports
        };
    }
    
    // Compile dashboard.html
    const dashboardTemplatePath = path.join(__dirname, '..', 'references', 'dashboard-template.html');
    if (fs.existsSync(dashboardTemplatePath)) {
        try {
            let dashboardHtml = fs.readFileSync(dashboardTemplatePath, 'utf8');
            console.log('DEBUG: Compiling dashboard.html with language:', workspaceLang);
            const currentTranslations = translations[workspaceLang] || translations['en'];
            console.log('DEBUG: Keys in currentTranslations:', Object.keys(currentTranslations));
            for (const key in currentTranslations) {
                if (key === 'dashboardTitle') {
                    console.log('DEBUG: replacing dashboardTitle with:', currentTranslations[key]);
                    console.log('DEBUG: before replace, html contains title placeholder:', dashboardHtml.includes('/* TRANSLATE:dashboardTitle */'));
                }
                dashboardHtml = dashboardHtml.replaceAll(`/* TRANSLATE:${key} */`, currentTranslations[key]);
                if (key === 'dashboardTitle') {
                    console.log('DEBUG: after replace, html contains title placeholder:', dashboardHtml.includes('/* TRANSLATE:dashboardTitle */'));
                }
            }
            
            const relativeReadmeFromTarget = 'README.html';
            const relativeSearchIndexUrl = 'search-index.js';
            
            const now = new Date();
            const renderTime = now.toLocaleString(workspaceLang === 'vi' ? 'vi-VN' : 'en-US', {
                year: 'numeric',
                month: '2-digit',
                day: '2-digit',
                hour: '2-digit',
                minute: '2-digit',
                second: '2-digit'
            });
            
            const sidebarHtml = ''; // Dashboard runs inside Portal iframe, no sidebar needed
            
            const allMdFilesRelative = allMdFiles.map(filePath => path.relative(srcDir, filePath).replace(/\\/g, '/'));
            
            dashboardHtml = dashboardHtml
                .replaceAll('/* WORKSPACE_LANG */', workspaceLang)
                .replaceAll('/* README_RELATIVE_URL */', relativeReadmeFromTarget)
                .replaceAll('/* SEARCH_INDEX_RELATIVE_URL */', relativeSearchIndexUrl)
                .replaceAll('/* RENDER_TIME */', renderTime)
                .replaceAll('/* KERNEL_VERSION */', kernelVersion)
                .replaceAll('<!-- DOCS_LIST_PLACEHOLDER -->', sidebarHtml)
                .replace(/const dashboardStats = [^;]+;/, 'const dashboardStats = ' + JSON.stringify(dashboardStats, null, 2) + ';')
                .replace(/const graphNodesData = [^;]+;/, 'const graphNodesData = ' + JSON.stringify(processedNodesData, null, 2) + ';')
                .replace(/const allMarkdownFiles = [^;]+;/, 'const allMarkdownFiles = ' + JSON.stringify(allMdFilesRelative, null, 2) + ';')
                .replace(/const alignmentData = [^;]+;/, 'const alignmentData = ' + JSON.stringify(alignmentData, null, 2) + ';');
                
            fs.writeFileSync(path.join(destDir, 'dashboard.html'), dashboardHtml, 'utf8');
            console.log('📊 Compiled documentation quality Dashboard successfully.');

            // Compile Portal index.html
            const portalTemplatePath = path.join(__dirname, '..', 'references', 'portal-template.html');
            if (fs.existsSync(portalTemplatePath)) {
                try {
                    let portalHtml = fs.readFileSync(portalTemplatePath, 'utf8');
                    
                    portalHtml = portalHtml.replaceAll('/* WORKSPACE_LANG */', workspaceLang);
                    const currentTranslations = translations[workspaceLang] || translations['en'];
                    for (const key in currentTranslations) {
                        portalHtml = portalHtml.replaceAll(`/* TRANSLATE:${key} */`, currentTranslations[key]);
                    }
                    
                    const relativeSearchIndexUrl = 'search-index.js';
                    const portalSidebarHtml = treeToHtml(treeRoot, '', path.join(destDir, 'index.html'), srcDir, destDir);
                    
                    portalHtml = portalHtml
                        .replaceAll('/* SEARCH_INDEX_RELATIVE_URL */', relativeSearchIndexUrl)
                        .replaceAll('/* KERNEL_VERSION */', kernelVersion)
                        .replaceAll('<!-- DOCS_LIST_PLACEHOLDER -->', portalSidebarHtml);
                        
                    fs.writeFileSync(path.join(destDir, 'index.html'), portalHtml, 'utf8');
                    console.log('💻 Compiled Portal App Shell index.html successfully.');
                } catch (e) {
                    console.error('Error compiling index.html Portal:', e.message);
                }
            }

            // Compile Glossary Help help.html
            const helpTemplatePath = path.join(__dirname, '..', 'references', 'help-template.html');
            if (fs.existsSync(helpTemplatePath)) {
                try {
                    let helpHtml = fs.readFileSync(helpTemplatePath, 'utf8');
                    
                    helpHtml = helpHtml.replaceAll('/* WORKSPACE_LANG */', workspaceLang);
                    const currentTranslations = translations[workspaceLang] || translations['en'];
                    for (const key in currentTranslations) {
                        helpHtml = helpHtml.replaceAll(`/* TRANSLATE:${key} */`, currentTranslations[key]);
                    }
                    
                    fs.writeFileSync(path.join(destDir, 'help.html'), helpHtml, 'utf8');
                    console.log('📖 Compiled Glossary Help help.html successfully.');
                } catch (e) {
                    console.error('Error compiling help.html:', e.message);
                }
            }

            // Compile Developer Wiki pages recursively (supports subfolders like vi/ and en/)
            const wikiSourceDir = path.join(__dirname, '..', 'references', 'wiki');
            const wikiDestDir = path.join(destDir, 'wiki');
            if (fs.existsSync(wikiSourceDir)) {
                try {
                    function walkWikiAndCompile(currentSrcSubdir, currentDestSubdir) {
                        if (!fs.existsSync(currentDestSubdir)) {
                            fs.mkdirSync(currentDestSubdir, { recursive: true });
                        }
                        const items = fs.readdirSync(currentSrcSubdir);
                        for (const item of items) {
                            const srcPath = path.join(currentSrcSubdir, item);
                            const destPath = path.join(currentDestSubdir, item);
                            const stats = fs.statSync(srcPath);
                            
                            if (stats.isDirectory()) {
                                walkWikiAndCompile(srcPath, destPath);
                            } else if (item.endsWith('.md')) {
                                const targetHtmlPath = destPath.replace(/\.md$/, '.html');
                                renderSingleFile(srcPath, targetHtmlPath, treeRoot, srcDir, destDir, template, graphNodesMap, calculateBlastRadius);
                                const relWikiPath = path.relative(wikiSourceDir, srcPath);
                                console.log(`📚 Compiled Developer Wiki page ${relWikiPath} successfully.`);
                            }
                        }
                    }
                    walkWikiAndCompile(wikiSourceDir, wikiDestDir);
                } catch (e) {
                    console.error('Error compiling Developer Wiki:', e.message);
                }
            }
        } catch (e) {
            console.error('Error compiling dashboard.html:', e.message);
        }
    }
    
    // Write static search-index.js to output directory
    try {
        const searchIndexPath = path.join(destDir, 'search-index.js');
        fs.writeFileSync(searchIndexPath, 'window.searchIndexData = ' + JSON.stringify(searchIndex, null, 2) + ';', 'utf8');
    } catch (e) {
        console.error('Error writing search-index.js:', e.message);
    }
    
    lastBuildTimestamp = Date.now();
    console.log(`🎉 Compiled ${allMdFiles.length} documentation files into separate target directory:`);
    console.log(`   📂 ${destDir}`);
}

// Initial compile execution
try {
    renderDirectory(sourceDir, outputDir, templateContent);
} catch (err) {
    console.error('Fatal compilation error occurred:', err.message);
    process.exit(1);
}

// If --watch flag is set, run file watcher and internal HTTP Server
if (hasWatchFlag) {
    const PORT = 3000;
    
    // Create HTTP Server
    const server = http.createServer((req, res) => {
        // CORS Headers to allow requests from file:// protocols
        res.setHeader('Access-Control-Allow-Origin', '*');
        res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
        res.setHeader('Access-Control-Allow-Headers', 'Content-Type');
        
        // Handle preflight OPTIONS request
        if (req.method === 'OPTIONS') {
            res.writeHead(204);
            res.end();
            return;
        }
        
        // API Endpoint 1: Retrieve latest build timestamp for browser reload checking
        if (req.method === 'GET' && req.url === '/reload-status') {
            res.writeHead(200, { 'Content-Type': 'application/json' });
            res.end(JSON.stringify({ lastBuild: lastBuildTimestamp }));
            return;
        }

        // API Endpoint 3: Open file in IDE directly from Node server
        if (req.method === 'POST' && req.url === '/api/open-file') {
            let body = '';
            req.on('data', chunk => {
                body += chunk.toString();
            });
            req.on('end', () => {
                try {
                    const payload = JSON.parse(body);
                    const filePath = payload.file;
                    if (filePath && fs.existsSync(filePath)) {
                        const { exec } = require('child_process');
                        const platform = process.platform;
                        let command = '';
                        
                        if (platform === 'win32') {
                            command = `start "" "${filePath}"`;
                        } else if (platform === 'darwin') {
                            command = `open "${filePath}"`;
                        } else {
                            command = `xdg-open "${filePath}"`;
                        }
                        
                        exec(command);
                        res.writeHead(200, { 'Content-Type': 'application/json' });
                        res.end(JSON.stringify({ success: true }));
                    } else {
                        res.writeHead(400, { 'Content-Type': 'application/json' });
                        res.end(JSON.stringify({ success: false, message: 'File not found or invalid path' }));
                    }
                } catch (e) {
                    res.writeHead(400, { 'Content-Type': 'application/json' });
                    res.end(JSON.stringify({ success: false, message: 'Invalid JSON payload' }));
                }
            });
            return;
        }
        
        // API Endpoint 2: Receive comment edits from client, saving to .beads/feedback.json
        if (req.method === 'POST' && req.url === '/api/feedback') {
            let body = '';
            req.on('data', chunk => {
                body += chunk.toString();
            });
            req.on('end', () => {
                try {
                    const feedback = JSON.parse(body);
                    
                    // Alert Agent console with structured layout
                    console.log('\n======================================================');
                    console.log('💬 DOCS VIEWER AGENT FEEDBACK SUBMISSION:');
                    console.log(`- File Source:  ${feedback.file}`);
                    console.log(`- Heading Sec:  ${feedback.section}`);
                    console.log(`- Edit Request: "${feedback.comment}"`);
                    console.log('======================================================\n');
                    
                    // Write feedback into project's active .beads directory
                    let projectBeadsDir = path.join(process.cwd(), '.beads');
                    const matchProject = feedback.file.match(/Projects\/([^\/]+)/);
                    if (matchProject) {
                        projectBeadsDir = path.join(process.cwd(), 'Projects', matchProject[1], '.beads');
                    }
                    
                    if (!fs.existsSync(projectBeadsDir)) {
                        fs.mkdirSync(projectBeadsDir, { recursive: true });
                    }
                    
                    const feedbackFile = path.join(projectBeadsDir, 'feedback.json');
                    let feedbacks = [];
                    if (fs.existsSync(feedbackFile)) {
                        try {
                            feedbacks = JSON.parse(fs.readFileSync(feedbackFile, 'utf8'));
                        } catch (e) {}
                    }
                    feedbacks.push(feedback);
                    fs.writeFileSync(feedbackFile, JSON.stringify(feedbacks, null, 2), 'utf8');
                    
                    res.writeHead(200, { 'Content-Type': 'application/json' });
                    res.end(JSON.stringify({ success: true, message: 'Feedback stored successfully' }));
                } catch (err) {
                    res.writeHead(400, { 'Content-Type': 'application/json' });
                    res.end(JSON.stringify({ success: false, message: 'Invalid JSON request payload' }));
                }
            });
            return;
        }
        // Serve static files from outputDir
        if (req.method === 'GET') {
            const urlParsed = new URL(req.url, `http://${req.headers.host || 'localhost'}`);
            let pathname = urlParsed.pathname;
            if (pathname === '/') {
                pathname = '/index.html';
            }
            
            const targetPath = path.join(outputDir, pathname);
            const normalizedTarget = path.normalize(targetPath);
            
            if (normalizedTarget.startsWith(outputDir) && fs.existsSync(normalizedTarget) && fs.statSync(normalizedTarget).isFile()) {
                const ext = path.extname(normalizedTarget).toLowerCase();
                const mimeTypes = {
                    '.html': 'text/html; charset=utf-8',
                    '.css': 'text/css; charset=utf-8',
                    '.js': 'text/javascript; charset=utf-8',
                    '.json': 'application/json; charset=utf-8',
                    '.png': 'image/png',
                    '.jpg': 'image/jpeg',
                    '.gif': 'image/gif',
                    '.svg': 'image/svg+xml',
                    '.ico': 'image/x-icon'
                };
                
                res.writeHead(200, { 'Content-Type': mimeTypes[ext] || 'application/octet-stream' });
                fs.createReadStream(normalizedTarget).pipe(res);
                return;
            }
        }
        
        res.writeHead(404);
        res.end();
    });

    server.listen(PORT, () => {
        console.log(`📡 Local Watch Server running at http://localhost:${PORT}`);
        console.log(`👀 Watching for documentation file modifications in: ${sourceDir}... (Press Ctrl+C to stop)`);
    });
    
    server.on('error', (err) => {
        if (err.code === 'EADDRINUSE') {
            console.warn(`⚠️ Port ${PORT} already in use. Live reload and feedback will use offline fallback mechanisms.`);
        } else {
            console.error('Server startup exception:', err.message);
        }
    });
    
    // File change observer logic with basic debouncer
    let debounceTimer = null;
    function triggerRebuild() {
        if (debounceTimer) clearTimeout(debounceTimer);
        debounceTimer = setTimeout(() => {
            console.log('\n🔄 Documentation change detected. Auto-recompiling...');
            try {
                renderDirectory(sourceDir, outputDir, templateContent);
            } catch (err) {
                console.error('Auto-compilation failure occurred:', err.message);
            }
        }, 300);
    }
    
    fs.watch(sourceDir, { recursive: true }, (eventType, filename) => {
        if (filename && filename.endsWith('.md')) {
            triggerRebuild();
        }
    });
}
