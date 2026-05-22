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
        alertCopySuccess: "🎉 Đã copy yêu cầu chỉnh sửa tài liệu vào clipboard!\\n\\n",
        alertServerSuccess: "📬 Watch server của Agent đã nhận yêu cầu ghi đĩa.\\n",
        alertInstructions: "👉 Hãy quay lại khung chat và dán (Ctrl+V) để Agent xử lý ngay.",
        alertError: "Đã xảy ra lỗi khi render tài liệu",
        alertManualCopy: "Hãy copy tay yêu cầu này để dán cho Agent nếu clipboard bị chặn",
        calloutNote: "Ghi chú:",
        calloutTip: "Gợi ý:",
        calloutImportant: "Quan trọng:",
        calloutWarning: "Cảnh báo:",
        calloutCaution: "Lưu ý nguy hiểm:"
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
        alertCopySuccess: "🎉 Document edit request copied to clipboard!\\n\\n",
        alertServerSuccess: "📬 Agent watch server received the write request.\\n",
        alertInstructions: "👉 Go back to chat box and Paste (Ctrl+V) to execute.",
        alertError: "Error occurred while rendering document",
        alertManualCopy: "Please copy this request manually to paste if clipboard access is blocked",
        calloutNote: "Note:",
        calloutTip: "Tip:",
        calloutImportant: "Important:",
        calloutWarning: "Warning:",
        calloutCaution: "Caution:"
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
        return childrenHtml;
    }
    
    if (!childrenHtml.trim()) return '';
    
    return `
    <li class="tree-folder">
        <div class="folder-toggle">
            <span class="chevron-icon-container"><i data-lucide="chevron-down"></i></span>
            <i data-lucide="folder"></i> ${node.name}
        </div>
        <ul class="folder-content">
            ${childrenHtml}
        </ul>
    </li>`;
}

// Render a single Markdown file to HTML using the template
function renderSingleFile(sourceFile, targetFile, treeRoot, rootDir, rootOutputDir, template) {
    try {
        const markdownContent = fs.readFileSync(sourceFile, 'utf8');
        
        // Escape special chars to prevent breaking JS template literals
        const escapedMarkdown = markdownContent
            .replace(/\\/g, '\\\\')
            .replace(/`/g, '\\`')
            .replace(/\${/g, '\\${');
            
        const relativeSourcePath = path.relative(process.cwd(), sourceFile);
        const absoluteSourcePath = path.resolve(sourceFile);
        const docCleanName = getMarkdownCleanName(sourceFile);
        
        const sidebarHtml = treeToHtml(treeRoot, sourceFile, targetFile, rootDir, rootOutputDir);
        
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
    
    const searchIndex = [];
    for (const sourceFile of allMdFiles) {
        const relativeFromRoot = path.relative(srcDir, sourceFile);
        const targetFile = path.join(destDir, relativeFromRoot.replace(/\.md$/, '.html'));
        renderSingleFile(sourceFile, targetFile, treeRoot, srcDir, destDir, template);
        
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
