const fs = require('fs');
const path = require('path');
const http = require('http');

// Global maps to coordinate graph-based CSA resolution
let anchorToCodeNodesMap = null;
let nodeToCodeDocsMap = {};
let hasGraph = false;
let existingSpecAnchorIds = new Set();

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
        const kernelMatch = configText.match(/^kernel_version:\s*["']?([0-9.]+)["']?/m);
        if (kernelMatch) {
            kernelVersion = kernelMatch[1];
        }
    } catch (e) {
        console.warn('Warning: Failed to parse .para-workspace.yml, falling back to English.');
    }
}

// Read project.md calibration config
const projectMdPath = path.join(path.dirname(sourceDir), 'project.md');
let projectCalibration = {
    exclude_folders: [],
    weights: {
        critical: 5.0,
        medium: 2.0,
        low: 0.5,
        god_node_degree_threshold: 20
    }
};

if (fs.existsSync(projectMdPath)) {
    try {
        const content = fs.readFileSync(projectMdPath, 'utf8');
        const match = content.match(/^---([\s\S]*?)---/);
        if (match) {
            const yamlText = match[1];
            const lines = yamlText.split('\n');
            let inCsa = false;
            let inCalibration = false;
            let currentKey = null;
            
            for (let line of lines) {
                const trimmed = line.trim();
                if (!trimmed || trimmed.startsWith('#')) continue;
                
                const indent = line.match(/^(\s*)/)[0].length;
                
                if (indent === 0) {
                    if (trimmed.startsWith('csa:')) {
                        inCsa = true;
                    } else {
                        inCsa = false;
                        inCalibration = false;
                    }
                } else if (inCsa && indent > 0) {
                    if (trimmed.startsWith('calibration:')) {
                        inCalibration = true;
                    } else if (inCalibration) {
                        if (trimmed.startsWith('exclude_folders:')) {
                            currentKey = 'exclude_folders';
                        } else if (trimmed.startsWith('weights:')) {
                            currentKey = 'weights';
                        } else if (trimmed.startsWith('-') && currentKey === 'exclude_folders') {
                            const folder = trimmed.substring(1).trim().replace(/['"]/g, '');
                            projectCalibration.exclude_folders.push(folder);
                        } else if (currentKey === 'weights') {
                            const parts = trimmed.split(':');
                            if (parts.length === 2) {
                                const wKey = parts[0].trim();
                                const wVal = parseFloat(parts[1].trim());
                                if (!isNaN(wVal)) {
                                    projectCalibration.weights[wKey] = wVal;
                                }
                            }
                        }
                    }
                }
            }
        }
    } catch (e) {
        console.warn('Warning: Failed to parse project.md calibration config:', e.message);
    }
}

const isExcluded = (filePath) => {
    if (!filePath) return false;
    const normalized = filePath.replace(/\\/g, '/');
    return projectCalibration.exclude_folders.some(folder => normalized.startsWith(folder));
};

// Multi-language dictionary translations
const translations = {
    vi: {
        title: "Tài liệu PARA Workspace",
        rightSidebarHeader: "Chi tiết & Mục lục",
        metaAuthor: "Tác giả",
        metaVersion: "Phiên bản",
        metaUpdated: "Cập nhật",
        metaStatus: "Trạng thái",
        metaProject: "Dự án",
        metaContext: "Bối cảnh",
        metaDescription: "Mô tả",
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
        scoreCardTitle: "Trạng thái Sức khỏe tổng thể",
        scoreLabel: "Sức khỏe tổng thể",
        totalDocs: "Tổng số tài liệu",
        graphNodes: "Cấu phần Đồ thị",
        businessGodNodes: "Thành phần Lõi Nghiệp vụ (God Nodes)",
        healthStatus: "Độ đồng bộ tài liệu",
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
        filterUnlinkedDocs: "Chưa neo (CSA trên Docs)",
        filterUnlinkedCode: "Chưa cmt (CSA trên Code)",
        filterDangling: "Neo mồ côi (Dangling)",
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
        thDocLinksDocs: "CSA trên Docs",
        thDocLinksSpecs: "CSA trên Specs",
        thDocLinksCode: "CSA trên Code",
        thDescription: "Mô tả / Ngữ nghĩa Hệ thống",
        hotspotsTitle: "⚠️ Điểm nóng ưu tiên",
        hotspotsSubtitle: "Thành phần ảnh hưởng lớn cần viết tài liệu",
        badgeStale: "Cần cập nhật",
        badgeLinkedDocs: "Đã neo (Docs)",
        badgeUnlinkedDocs: "Chưa neo (Docs)",
        badgeLinkedCode: "Đã cmt (Code)",
        badgeUnlinkedCode: "Chưa cmt (Code)",
        calibrationVerifyComments: "Kiểm tra comment neo trong mã nguồn (CSA trên Code)",
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
        alignmentTitle: "Đối soát Đặc tả & Mã nguồn (Docs-Code Alignment Audit)",
        alignmentDocLabel: "Đặc tả:",
        alignmentDecisionTable: "Bảng quyết định nghiệp vụ (Decision Table)",
        alignmentAiPrompts: "Đề xuất Tác vụ AI (AI Assistant Prompts)",
        alignmentDriftAudit: "Báo cáo sai lệch & Gaps (Drift Audit)",
        driftDocsTitle: "🔍 Tài liệu bị lệch (Drift)",
        driftDocsSubtitle: "Tài liệu có neo liên kết hỏng hoặc sai lệch với mã nguồn",
        calibrationDesc: "Trọng số đại diện cho độ quan trọng tương đối của từng cấu phần mã:<br/>• <b>Cốt lõi:</b> Các cấu phần lõi ảnh hưởng lớn (Cấu phần Siêu kết nối, độ kết nối >= 20).<br/>• <b>Trung bình:</b> Hàm, lớp, tệp tin tiêu chuẩn.<br/>• <b>Bổ trợ:</b> Các biến và hằng số phụ trợ.<br/>Tài liệu hóa phần Cốt lõi đóng góp điểm số cao hơn.",
        navHome: "Tài liệu chính (README)",
        navBack: "Trở lại",
        navForward: "Tiến tới",
        aiPromptsTitle: "Gợi ý Prompt AI",
        aiPromptsFrontmatter: "Chuẩn hóa Frontmatter",
        aiPromptsDriftAudit: "Rà soát sai lệch & Gaps (Drift Audit)",
        aiPromptsReview: "Rà soát & Cập nhật tài liệu",
        aiPromptsReviewStructure: "Review cấu trúc tài liệu",
        aiPromptsStrategy: "Xây dựng & Xem lại Chiến lược",
        aiPromptsHeadings: "Chuẩn hóa Đánh số Tiêu đề",
        toastPromptCopied: "🎉 Đã sao chép prompt AI gợi ý vào clipboard!",
        driftAuditShort: "Kiểm toán sai lệch",
        driftAuditNoIssues: "0 phát hiện",
        driftAuditIssues: "phát hiện",
        docStatHealth: "Sức khỏe",
        docStatHealthDesc: "Tỷ lệ liên kết hai chiều (Docs ↔ Code) của tài liệu này",
        docStatAnchors: "CSA trên Docs",
        docStatAnchorsDesc: "Số cấu phần mã được liên kết xuôi từ tài liệu (CSA trên Docs)",
        docStatComments: "CSA trên Code",
        docStatCommentsDesc: "Số cấu phần mã chứa comment liên kết ngược trong code (CSA trên Code)",
        docStatEntities: "Cấu phần",
        docStatEntitiesDesc: "Tổng số cấu phần mã liên quan đến tài liệu này",
        metadataTitle: "Thông tin tài liệu",
        statHealthScore: "Sức khỏe",
        statHealthScoreDesc: "Điểm sức khỏe tài liệu dựa trên trọng số liên kết hai chiều",
        statCoverage: "Độ phủ",
        statCoverageDesc: "Tỷ lệ cấu phần mã đã được liên kết tài liệu (Neo/Tổng số)",
        statStale: "Cần sửa",
        statStaleDesc: "Số lượng cấu phần tài liệu bị cũ/lệch so với mã nguồn thực tế",
        statTotalDocs: "Tài liệu",
        statTotalDocsDesc: "Tổng số tệp tài liệu kỹ thuật trong dự án",
        weightedCoverageLabel: "Độ bao phủ Đồ thị",
        syncRateLabel: "Độ đồng bộ tài liệu",
        pdfExportTitle: "Xuất tệp PDF (Phân trang thông minh)",
        pdfModalTitle: "Cấu hình in PDF (Smart PDF)",
        pdfModalDesc: "Chọn cấu hình định dạng xuất bản in PDF cho tài liệu này:",
        pdfOptionNoToc: "Không in mục lục",
        pdfOptionNoTocDesc: "Không đính kèm trang mục lục vào bản in PDF.",
        pdfOptionSeparatePage: "In mục lục ở trang riêng",
        pdfOptionSeparatePageDesc: "Mục lục xuất hiện ở trang số 1, ngắt trang sang nội dung chính.",
        pdfOptionInline: "In mục lục ở đầu trang",
        pdfOptionInlineDesc: "Mục lục in liền kề trước nội dung chính (không ngắt trang).",
        pdfPrintBtn: "Xác nhận In",
        pdfToggleHeaderFooter: "In tiêu đề & chân trang tài liệu",
        pdfHeaderSectionLabel: "Cấu hình tiêu đề đầu trang (Header)",
        pdfFooterSectionLabel: "Cấu hình chân trang (Footer)",
        pdfLeftPos: "Bên trái",
        pdfCenterPos: "Chính giữa",
        pdfRightPos: "Bên phải",
        pdfOptNone: "Trống",
        pdfOptDocTitle: "Tiêu đề tài liệu",
        pdfOptFileName: "Tên tệp (VD: file.md)",
        pdfOptFilePath: "Đường dẫn tệp (VD: Projects/...)",
        pdfOptDate: "Ngày in hiện tại",
        pdfOptVersion: "Phiên bản Kernel",
        pdfOptCustom: "Nhập tay tùy chọn...",
        pdfCustomPlaceholderPrefix: "Nhập chữ cho ô ",
        pdfToggleCoverPage: "Tạo trang bìa thông tin file (Metadata)",
        pdfCoverPageDesc: "Tạo một trang bìa riêng biệt ở trang số 1 hiển thị Tên tài liệu, Dự án và thông tin Metadata (Người viết, Ngày cập nhật, Trạng thái...)."
    },
    en: {
        title: "PARA Workspace Docs",
        rightSidebarHeader: "Details & Outline",
        metaAuthor: "Author",
        metaVersion: "Version",
        metaUpdated: "Updated",
        metaStatus: "Status",
        metaProject: "Project",
        metaContext: "Context",
        metaDescription: "Description",
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
        scoreCardTitle: "Overall Health Status",
        scoreLabel: "Overall Health",
        totalDocs: "Total Documents",
        graphNodes: "Graph Nodes",
        businessGodNodes: "Business God Nodes",
        healthStatus: "Doc Sync Rate",
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
        filterUnlinkedDocs: "CSA on Docs Unlinked",
        filterUnlinkedCode: "CSA on Code Unlinked",
        filterDangling: "Dangling CSA Links",
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
        thDocLinksDocs: "CSA on Docs",
        thDocLinksSpecs: "CSA on Specs",
        thDocLinksCode: "CSA on Code",
        thDescription: "Description / System Semantics",
        hotspotsTitle: "⚠️ Priority Hotspots",
        hotspotsSubtitle: "High-impact components lacking docs",
        badgeStale: "Stale / Outdated",
        badgeLinkedDocs: "Anchored (Docs)",
        badgeUnlinkedDocs: "Unanchored (Docs)",
        badgeLinkedCode: "Commented (Code)",
        badgeUnlinkedCode: "Uncommented (Code)",
        calibrationVerifyComments: "Verify code comment references (CSA on Code)",
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
        alignmentTitle: "Docs-Code Alignment Audit",
        alignmentDocLabel: "Spec Document:",
        alignmentDecisionTable: "Business Decision Table",
        alignmentAiPrompts: "AI Assistant Task Prompts",
        alignmentDriftAudit: "Logic Drift & Gaps Audit",
        driftDocsTitle: "🔍 Outdated Specs (Drift)",
        driftDocsSubtitle: "Specs with broken anchor links or outdated code references",
        calibrationDesc: "Weights represent the relative priority of each individual code entity:<br/>• <b>Critical:</b> High-impact core components (God Nodes, degree >= 20).<br/>• <b>Medium:</b> Standard functions, classes, and source files.<br/>• <b>Low:</b> Auxiliary variables and constants.<br/>Documenting Critical components contributes more to the overall health score.",
        navHome: "Main Documentation (README)",
        navBack: "Go Back",
        navForward: "Go Forward",
        aiPromptsTitle: "AI Prompt Suggestions",
        aiPromptsFrontmatter: "Normalize Frontmatter",
        aiPromptsDriftAudit: "Review Logic Drift & Gaps",
        aiPromptsReview: "Review & Update Docs",
        aiPromptsReviewStructure: "Review Docs Structure",
        aiPromptsStrategy: "Build & Review Strategy",
        aiPromptsHeadings: "Normalize Headings Numbering",
        toastPromptCopied: "🎉 Copied AI prompt suggestion to clipboard!",
        driftAuditShort: "Drift Audit",
        driftAuditNoIssues: "0 issues",
        driftAuditIssues: "findings",
        docStatHealth: "Health",
        docStatHealthDesc: "Double-binding rate (Docs ↔ Code) of this document",
        docStatAnchors: "CSA on Docs",
        docStatAnchorsDesc: "Number of code entities linked from document (CSA on Docs)",
        docStatComments: "CSA on Code",
        docStatCommentsDesc: "Number of code entities containing backward comments in code (CSA on Code)",
        docStatEntities: "Entities",
        docStatEntitiesDesc: "Total code entities associated with this document",
        metadataTitle: "Document Metadata",
        statHealthScore: "Health",
        statHealthScoreDesc: "Weighted double-binding documentation health score",
        statCoverage: "Coverage",
        statCoverageDesc: "Ratio of documented code entities in graph",
        statStale: "Stale",
        statStaleDesc: "Count of outdated doc references relative to source code",
        statTotalDocs: "Docs",
        statTotalDocsDesc: "Total documentation files count",
        weightedCoverageLabel: "Weighted Graph Coverage",
        syncRateLabel: "Doc Sync Rate",
        pdfExportTitle: "Export PDF (Smart Pagination)",
        pdfModalTitle: "Smart PDF Export Settings",
        pdfModalDesc: "Select the PDF print layout format for this document:",
        pdfOptionNoToc: "No Table of Contents",
        pdfOptionNoTocDesc: "Do not include the TOC in the printed PDF.",
        pdfOptionSeparatePage: "TOC on separate page",
        pdfOptionSeparatePageDesc: "The TOC appears on page 1, then page-breaks to the main content.",
        pdfOptionInline: "TOC inline / continuous",
        pdfOptionInlineDesc: "The TOC is printed directly before the main content (no page break).",
        pdfPrintBtn: "Print",
        pdfToggleHeaderFooter: "Print document header & footer",
        pdfHeaderSectionLabel: "Configure Page Header",
        pdfFooterSectionLabel: "Configure Page Footer",
        pdfLeftPos: "Left Zone",
        pdfCenterPos: "Center Zone",
        pdfRightPos: "Right Zone",
        pdfOptNone: "Empty",
        pdfOptDocTitle: "Document Title",
        pdfOptFileName: "File Name (e.g. file.md)",
        pdfOptFilePath: "File Path (e.g. Projects/...)",
        pdfOptDate: "Current Date",
        pdfOptVersion: "Kernel Version",
        pdfOptCustom: "Custom Text...",
        pdfCustomPlaceholderPrefix: "Enter text for ",
        pdfToggleCoverPage: "Generate File Metadata Cover Page",
        pdfCoverPageDesc: "Creates a separate cover page on Page 1 displaying Document Title, Project name, and Metadata (Author, Status, Updated date, etc.)."
    }
};

// Stores timestamp of the latest build for browser hot-reloading
let lastBuildTimestamp = Date.now();

// Extract clean display name from Markdown filename (remove .md)
function getMarkdownCleanName(filePath) {
    return path.basename(filePath, '.md');
}

// Simple parser for YAML Frontmatter to extract order/weight
function parseFrontmatter(content) {
    const match = content.match(/^---\r?\n([\s\S]*?)\r?\n---/);
    if (!match) return { frontmatter: {}, content: content };
    const yamlText = match[1];
    const frontmatter = {};
    const lines = yamlText.split('\n');
    for (const line of lines) {
        const colonIndex = line.indexOf(':');
        if (colonIndex > 0) {
            const key = line.substring(0, colonIndex).trim();
            const val = line.substring(colonIndex + 1).trim();
            if (/^\d+(\.\d+)?$/.test(val)) {
                frontmatter[key] = Number(val);
            } else {
                frontmatter[key] = val.replace(/^["']|["']$/g, '');
            }
        }
    }
    const cleanContent = content.substring(match[0].length);
    return { frontmatter, content: cleanContent };
}

// Parse folder order list from README.md Structure table
function getFolderOrderFromReadme(readmePath) {
    const orderList = [];
    if (fs.existsSync(readmePath)) {
        try {
            const content = fs.readFileSync(readmePath, 'utf8');
            const matches = content.matchAll(/`([^`\/\s\r\n]+)\/?`/g);
            for (const match of matches) {
                const folderName = match[1].trim();
                if (!orderList.includes(folderName) && folderName !== 'README') {
                    orderList.push(folderName);
                }
            }
        } catch (e) {
            console.warn('Warning: Failed to parse folders order from README.md');
        }
    }
    return orderList;
}

// Recursively construct Folder Tree JSON
function buildTree(dirPath, rootDir, folderOrderList = []) {
    const stats = fs.statSync(dirPath);
    const node = {
        name: path.basename(dirPath),
        path: dirPath,
        isDirectory: stats.isDirectory(),
        title: stats.isDirectory() ? null : getMarkdownCleanName(dirPath),
        order: 999999
    };
    
    if (!node.isDirectory) {
        if (path.extname(dirPath) === '.md') {
            try {
                const content = fs.readFileSync(dirPath, 'utf8');
                const { frontmatter } = parseFrontmatter(content);
                node.order = frontmatter.order !== undefined ? frontmatter.order : 999999;
            } catch (e) {
                node.order = 999999;
            }
        }
    } else {
        const relPath = path.relative(rootDir, dirPath);
        if (relPath && !relPath.includes(path.sep)) {
            const idx = folderOrderList.indexOf(node.name);
            node.order = idx !== -1 ? idx + 1 : 999999;
        }
    }
    
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
                
            node.children.push(buildTree(childPath, rootDir, folderOrderList));
        }
        
        node.children.sort((a, b) => {
            if (a.isDirectory && !b.isDirectory) return -1;
            if (!a.isDirectory && b.isDirectory) return 1;
            
            const orderA = a.order !== undefined ? a.order : 999999;
            const orderB = b.order !== undefined ? b.order : 999999;
            if (orderA !== orderB) {
                return orderA - orderB;
            }
            return a.name.localeCompare(b.name);
        });
        
        let folderCount = 0;
        let fileCount = 0;
        for (const child of node.children) {
            if (child.isDirectory) {
                folderCount++;
                child.displayOrder = folderCount;
            } else {
                fileCount++;
                child.displayOrder = fileCount;
            }
        }
    }
    return node;
}

// Helper to calculate virtual relative paths for docs, sysdesigns, specs, and writings
function getVirtualRelativePath(filePath, srcDir) {
    const projectDir = path.dirname(srcDir);
    const sysdesignsDir = path.join(projectDir, 'artifacts', 'sysdesigns');
    const specsDir = path.join(projectDir, 'artifacts', 'specs');
    const writingsDir = fs.existsSync(path.join(projectDir, 'writings'))
        ? path.join(projectDir, 'writings')
        : path.join(projectDir, 'artifacts', 'writings');
    
    const normFile = path.normalize(filePath);
    const normSys = path.normalize(sysdesignsDir);
    const normSpecs = path.normalize(specsDir);
    const normWritings = path.normalize(writingsDir);
    const normDocs = path.normalize(srcDir);
    
    if (fs.existsSync(sysdesignsDir) && normFile.startsWith(normSys)) {
        return path.join('sysdesigns', path.relative(sysdesignsDir, filePath)).replace(/\\/g, '/');
    } else if (fs.existsSync(specsDir) && normFile.startsWith(normSpecs)) {
        return path.join('specs', path.relative(specsDir, filePath)).replace(/\\/g, '/');
    } else if (fs.existsSync(writingsDir) && normFile.startsWith(normWritings)) {
        return path.join('writings', path.relative(writingsDir, filePath)).replace(/\\/g, '/');
    } else if (normFile.startsWith(normDocs)) {
        return path.join('docs', path.relative(srcDir, filePath)).replace(/\\/g, '/');
    } else {
        return path.relative(srcDir, filePath).replace(/\\/g, '/');
    }
}

// Convert Folder Tree JSON into HTML Sidebar navigation list
function treeToHtml(node, currentSourcePath, currentTargetPath, rootDir, rootOutputDir, srcDir) {
    if (!node.isDirectory) {
        if (path.extname(node.path) !== '.md') return '';
        
        const relativeFromRoot = getVirtualRelativePath(node.path, srcDir);
        const correspondingHtmlPath = path.join(rootOutputDir, relativeFromRoot.replace(/\.md$/, '.html'));
        
        let relativeUrl = path.relative(path.dirname(currentTargetPath), correspondingHtmlPath);
        relativeUrl = relativeUrl.replace(/\\/g, '/');
        
        const isActive = (node.path === currentSourcePath);
        const activeClass = isActive ? 'active' : '';
        const hrefValue = isActive ? '#' : relativeUrl;
        
        const relativeHtmlPathFromRoot = relativeFromRoot.replace(/\.md$/, '.html').replace(/\\/g, '/');
        
        const isSpecialDoc = ['readme.md', 'changelog.md'].includes(node.name.toLowerCase());
        const orderPrefix = (node.order !== undefined && node.order < 999999 && !isSpecialDoc) ? `${node.order}. ` : '';
        return `
        <li class="tree-item">
            <a href="${hrefValue}" class="menu-link ${activeClass}" data-docpath="${relativeHtmlPathFromRoot}">
                <i data-lucide="file-text"></i> ${orderPrefix}${node.title}
            </a>
        </li>`;
    }
    
    let childrenHtml = '';
    if (node.children) {
        for (const child of node.children) {
            childrenHtml += treeToHtml(child, currentSourcePath, currentTargetPath, rootDir, rootOutputDir, srcDir);
        }
    }
    
    if (node.path === rootDir) {
        return childrenHtml;
    }
    
    if (!childrenHtml.trim()) return '';
    
    const folderPrefix = (node.order !== undefined && node.order < 90000 && !node.hideOrder) ? `${node.order}. ` : '';
    return `
    <li class="tree-folder">
        <div class="folder-toggle">
            <span class="chevron-icon-container"><i data-lucide="chevron-right"></i></span>
            <i data-lucide="folder"></i> ${folderPrefix}${node.name}
        </div>
        <ul class="folder-content" style="display: none;">
            ${childrenHtml}
        </ul>
    </li>`;
}

// Render a single Markdown file to HTML using the template
function renderSingleFile(sourceFile, targetFile, treeRoot, rootDir, rootOutputDir, template, graphNodesMap, calculateBlastRadius, dashboardStats, auditReports, fileStats) {
    try {
        const rawContent = fs.readFileSync(sourceFile, 'utf8');
        const { frontmatter, content: markdownContent } = parseFrontmatter(rawContent);
        
        // Detect file language
        let fileLang = workspaceLang;
        const normalizedPath = sourceFile.replace(/\\/g, '/');
        if (normalizedPath.includes('/en/')) {
            fileLang = 'en';
        } else if (normalizedPath.includes('/vi/')) {
            fileLang = 'vi';
        }
        const currentTranslations = translations[fileLang] || translations['en'];
        
        // Build stats panel for specific document
        let statsPanelHtml = '';
        if (fileStats && fileStats.totalEntities > 0) {
            const doubleBound = fileStats.doubleBound;
            const totalEntities = fileStats.totalEntities;
            const docsToCode = fileStats.docsToCode;
            const codeToDocs = fileStats.codeToDocs;
            
            const healthRate = ((doubleBound / totalEntities) * 100).toFixed(1);
            
            statsPanelHtml = `
            <div class="stats-panel-container">
                <div class="stat-card" title="${currentTranslations['docStatHealthDesc'] || 'Double-binding rate of this document'}">
                    <span class="stat-value text-success">${healthRate}%</span>
                    <span class="stat-label">${currentTranslations['docStatHealth'] || 'Sức khỏe'}</span>
                </div>
                <div class="stat-card" title="${currentTranslations['docStatAnchorsDesc'] || 'Number of code entities anchored in this document'}">
                    <span class="stat-value">${docsToCode}/${totalEntities}</span>
                    <span class="stat-label">${currentTranslations['docStatAnchors'] || 'Độ phủ neo'}</span>
                </div>
                <div class="stat-card" title="${currentTranslations['docStatCommentsDesc'] || 'Number of code entities containing comments pointing to this document'}">
                    <span class="stat-value">${codeToDocs}/${totalEntities}</span>
                    <span class="stat-label">${currentTranslations['docStatComments'] || 'Comment code'}</span>
                </div>
                <div class="stat-card" title="${currentTranslations['docStatEntitiesDesc'] || 'Total code entities associated with this document'}">
                    <span class="stat-value">${totalEntities}</span>
                    <span class="stat-label">${currentTranslations['docStatEntities'] || 'Cấu phần'}</span>
                </div>
            </div>`;
        }


        // Build metadata panel (always show to support frontmatter suggestions)
        let metadataHtml = '';
        const metadataKeys = Object.keys(frontmatter).filter(k => k !== 'title' && k !== 'order');
        
        metadataHtml = `
        <div class="metadata-container">
            <button class="metadata-toggle-btn" id="metadata-toggle-btn" onclick="toggleMetadataDropdown()">
                <span style="display: flex; align-items: center; gap: 6px;">
                    <i data-lucide="info" style="width: 14px; height: 14px;"></i>
                    <span>${currentTranslations['metadataTitle'] || 'Metadata'}</span>
                </span>
                <i data-lucide="chevron-down" id="metadata-chevron" style="width: 14px; height: 14px; transition: transform 0.2s;"></i>
            </button>
            <div class="metadata-dropdown" id="metadata-dropdown">
                <div class="doc-metadata-panel">`;
                
        if (metadataKeys.length > 0) {
            for (const key of metadataKeys) {
                const val = frontmatter[key];
                if (val === undefined || val === null || val === '') continue;
                
                // Translate keys if possible
                let keyLabel = key.charAt(0).toUpperCase() + key.slice(1);
                const translationKey = `meta${keyLabel}`;
                if (currentTranslations[translationKey]) {
                    keyLabel = currentTranslations[translationKey];
                }
                
                let valueHtml = '';
                if (key === 'status') {
                    const statusStr = String(val).trim();
                    // Normalize accents and strip emojis to apply correct CSS classes
                    let cleanStatus = statusStr.normalize('NFD')
                        .replace(/[\u0300-\u036f]/g, '')
                        .replace(/[đĐ]/g, 'd')
                        .replace(/[\u2700-\u27BF]|[\uE000-\uF8FF]|\uD83C[\uDC00-\uDFFF]|\uD83D[\uDC00-\uDFFF]|[\u2011-\u26FF]|\uD83E[\uDD00-\uDFFF]/g, '')
                        .trim()
                        .toLowerCase();
                    cleanStatus = cleanStatus.replace(/\s+/g, '-').replace(/[^a-z0-9-]/g, '');
                    
                    let badgeClass = 'default';
                    if (['approved', 'done', 'completed', 'da-phe-duyet', 'da-hoan-thanh', 'active', 'hoat-dong'].includes(cleanStatus)) {
                        badgeClass = 'approved';
                    } else if (['draft', 'nhap', 'pending', 'dang-xu-ly', 'work-in-progress', 'wip'].includes(cleanStatus)) {
                        badgeClass = 'draft';
                    } else if (['stale', 'outdated', 'cu', 'het-han', 'expired'].includes(cleanStatus)) {
                        badgeClass = 'stale';
                    }
                    valueHtml = `<span class="status-badge ${badgeClass}">${statusStr}</span>`;
                } else {
                    valueHtml = `<span class="metadata-value">${val}</span>`;
                }
                
                metadataHtml += `
                        <div class="metadata-row">
                            <span class="metadata-key" title="${keyLabel}">${keyLabel}</span>
                            <div class="metadata-value-container">${valueHtml}</div>
                        </div>`;
            }
        } else {
            metadataHtml += `
                        <div style="font-size: 12px; color: var(--text-secondary); text-align: center; padding: 4px 0; font-style: italic; display: flex; align-items: center; gap: 6px; justify-content: center;">
                            <i data-lucide="alert-circle" style="width: 14px; height: 14px; color: #d97706;"></i>
                            <span>${fileLang === 'vi' ? 'Thiếu thông tin Frontmatter' : 'Missing Frontmatter metadata'}</span>
                        </div>`;
        }
        metadataHtml += `
                </div>
            </div>
        </div>`;
        
        // Build Drift Audit Panel
        let driftAuditHtml = '';
        if (auditReports) {
            const hasIssues = auditReports.length > 0;
            const issuesCount = auditReports.length;
            const statusClass = hasIssues ? '' : 'no-issues';
            
            let toggleLabel = '';
            let dropdownContent = '';
            
            if (hasIssues) {
                const titleText = currentTranslations['driftAuditShort'] || 'Kiểm toán sai lệch';
                const countSuffix = currentTranslations['driftAuditIssues'] || (fileLang === 'vi' ? 'phát hiện' : 'findings');
                const warningMsg = `${issuesCount} ${countSuffix}`;
                toggleLabel = `
                    <span style="display: flex; align-items: center; gap: 6px;">
                        <i data-lucide="alert-triangle" style="width: 14px; height: 14px;"></i>
                        <span>${titleText} (${warningMsg})</span>
                    </span>`;
                
                dropdownContent = `<div class="drift-audit-dropdown-list" style="display: flex; flex-direction: column; gap: 8px;">`;
                auditReports.forEach(r => {
                    const sevClass = r.severity || 'medium';
                    const tText = r.title || 'Gap';
                    const descText = r.description || '';
                    const solText = r.solution || '';
                    
                    dropdownContent += `
                        <div class="drift-issue-item ${sevClass}">
                            <span class="drift-issue-title">${tText}</span>
                            <span class="drift-issue-desc">${descText}</span>
                            ${solText ? `<span class="drift-issue-sol"><strong>${fileLang === 'vi' ? 'Đề xuất giải pháp:' : 'Proposed Solution:'}</strong> ${solText}</span>` : ''}
                        </div>`;
                });
                dropdownContent += `</div>`;
            } else {
                const titleText = currentTranslations['driftAuditShort'] || 'Kiểm toán sai lệch';
                const successMsg = currentTranslations['driftAuditNoIssues'] || (fileLang === 'vi' ? '0 phát hiện' : '0 issues');
                toggleLabel = `
                    <span style="display: flex; align-items: center; gap: 6px;">
                        <i data-lucide="check-circle" style="width: 14px; height: 14px;"></i>
                        <span>${titleText} (${successMsg})</span>
                    </span>`;
                dropdownContent = `
                    <div class="drift-no-issues-msg">
                        <i data-lucide="check-circle"></i>
                        <span>${fileLang === 'vi' ? 'Tuyệt vời! Tài liệu hoàn toàn khớp với logic mã nguồn hiện tại.' : 'Excellent! Documentation fully matches current source code.'}</span>
                    </div>`;
            }
            
            driftAuditHtml = `
            <div class="drift-audit-container">
                <button class="drift-audit-toggle-btn ${statusClass}" id="drift-audit-toggle-btn" onclick="toggleDriftAuditDropdown()">
                    ${toggleLabel}
                    <i data-lucide="chevron-down" id="drift-audit-chevron" style="width: 14px; height: 14px; transition: transform 0.2s;"></i>
                </button>
                <div class="drift-audit-dropdown" id="drift-audit-dropdown">
                    ${dropdownContent}
                </div>
            </div>`;
        }

        // Parse markdown content for Unified CSA <span id="csa-..."> anchors
        const nodeRegex = /<span\s+id=["'](csa-[a-zA-Z0-9.:\/_-]+)["'][^>]*><\/span>/g;
        const linkedNodeIds = [];
        let match;
        while ((match = nodeRegex.exec(markdownContent)) !== null) {
            const nodeId = match[1];
            if (!linkedNodeIds.includes(nodeId)) {
                linkedNodeIds.push(nodeId);
            }
        }

        let modifiedMarkdown = markdownContent;
        const isWiki = sourceFile.includes('/wiki/') || sourceFile.includes('\\wiki\\') || path.dirname(sourceFile).split(path.sep).includes('wiki');
        if (linkedNodeIds.length > 0 && graphNodesMap && !isWiki) {
            const projectDir = path.dirname(rootDir);

            const docNodesTitle = fileLang === 'vi' ? 'Các thành phần mã được tham chiếu' : 'Referenced Code Entities';
            const thEntity = fileLang === 'vi' ? 'Thành phần mã' : 'Entity';
            const thType = fileLang === 'vi' ? 'Phân loại' : 'Type';
            const thLocation = fileLang === 'vi' ? 'Vị trí' : 'Location';
            const thBlast = fileLang === 'vi' ? 'Bán kính ảnh hưởng (Blast)' : 'Blast Radius';
            const thDesc = fileLang === 'vi' ? 'Mô tả' : 'Description';
            
            let nodesListMarkdown = `\n\n---\n\n### <span style="display: flex; align-items: center; gap: 8px;"><i data-lucide="network" style="width: 18px; height: 18px; color: var(--accent-color);"></i> ${docNodesTitle}</span>\n\n`;
            nodesListMarkdown += `| ${thEntity} | ${thType} | ${thLocation} | ${thBlast} | ${thDesc} |\n`;
            nodesListMarkdown += `| :--- | :--- | :--- | :---: | :--- |\n`;
            
            for (const nodeId of linkedNodeIds) {
                let resolvedNodes = [];
                if (hasGraph && anchorToCodeNodesMap && anchorToCodeNodesMap[nodeId]) {
                    resolvedNodes = anchorToCodeNodesMap[nodeId];
                } else {
                    // Fallback to name-based heuristic if no graph or not found in map
                    const cleanId = nodeId.startsWith('csa-') ? nodeId.substring(4) : nodeId;
                    let node = graphNodesMap[cleanId];
                    if (!node) {
                        node = graphNodesMap[nodeId] || Object.values(graphNodesMap).find(n => n.name === cleanId || n.id === cleanId || n.id.endsWith('::' + cleanId));
                    }
                    if (node) {
                        resolvedNodes.push(node);
                    }
                }
                
                for (const node of resolvedNodes) {
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

        // Build detailed audit text for AI prompt suggestions
        const auditDetailsText = auditReports && auditReports.length > 0 ? auditReports.map((r, idx) => {
            const severityLabel = r.severity ? `[${r.severity.toUpperCase()}] ` : '';
            const solutionText = r.solution ? (fileLang === 'vi' ? `\n   - Giải pháp đề xuất: ${r.solution}` : `\n   - Proposed Solution: ${r.solution}`) : '';
            return `${idx + 1}. ${severityLabel}**[${r.title}]** ${r.description}${solutionText}`;
        }).join('\n') : (fileLang === 'vi' ? 'Không phát hiện sai lệch.' : 'No drift issues detected.');

        const escapedAuditDetails = auditDetailsText
            .replace(/\\/g, '\\\\')
            .replace(/`/g, '\\`')
            .replace(/\${/g, '\\${')
            .replace(/'/g, "\\'")
            .replace(/"/g, '\\"');
            
        // Build dynamic AI Prompt Suggestions based on document status
        const frontmatterKeys = Object.keys(frontmatter).filter(k => k !== 'title' && k !== 'order');
        const needsFrontmatter = frontmatterKeys.length === 0;

        const headers = [];
        const headerRegex = /^(#{1,6})\s+(.+)$/gm;
        let hMatch;
        headerRegex.lastIndex = 0;
        while ((hMatch = headerRegex.exec(rawContent)) !== null) {
            headers.push(hMatch[2].trim());
        }
        let hasHeadingIssues = false;
        let lastNum = 0;
        for (const h of headers) {
            const match = h.match(/^(\d+(?:\.\d+)*)\.?\s+/);
            if (match) {
                const parts = match[1].split('.').map(Number);
                const firstLevel = parts[0];
                if (!isNaN(firstLevel)) {
                    if (firstLevel > lastNum + 1) {
                        hasHeadingIssues = true;
                        break;
                    }
                    if (firstLevel >= lastNum) {
                        lastNum = firstLevel;
                    }
                }
            }
        }

        const hasBrokenAnchors = auditReports && auditReports.some(r => r.title && (r.title.includes('Broken Anchor') || r.title.includes('neo liên kết hỏng') || r.title.includes('Neo liên kết hỏng')));
        const hasBrokenCodeDocs = auditReports && auditReports.some(r => r.title && (r.title.includes('Broken @para-doc') || r.title.includes('neo @para-doc hỏng') || r.title.includes('Neo @para-doc hỏng')));
        const hasGaps = auditReports && auditReports.some(r => r.title && (r.title.includes('GAP') || r.severity === 'high'));

        const isStrategyDoc = normalizedPath.includes('strategy.md') || normalizedPath.includes('strategy-documentation.md') || normalizedPath.includes('/strategy/');
        const promptItems = [
            {
                key: 'frontmatter',
                label: currentTranslations['aiPromptsFrontmatter'] || 'Normalize Frontmatter',
                recommended: needsFrontmatter,
                badge: fileLang === 'vi' ? 'Thiếu Metadata' : 'Missing Metadata',
                badgeType: 'attention'
            },
            {
                key: 'drift-audit',
                label: currentTranslations['aiPromptsDriftAudit'] || 'Review Logic Drift & Gaps',
                recommended: hasBrokenAnchors || hasBrokenCodeDocs || hasGaps,
                badge: fileLang === 'vi' ? 'Sai Lệch' : 'Logic Drift',
                badgeType: 'attention'
            },
            {
                key: 'headings',
                label: currentTranslations['aiPromptsHeadings'] || 'Normalize Headings Numbering',
                recommended: hasHeadingIssues,
                badge: fileLang === 'vi' ? 'Lệch Tiêu Đề' : 'Bad Numbering',
                badgeType: 'attention'
            },
            {
                key: 'review-structure',
                label: currentTranslations['aiPromptsReviewStructure'] || 'Review Docs Structure',
                recommended: true,
                badge: fileLang === 'vi' ? 'Tối Ưu' : 'Optimize',
                badgeType: 'suggest'
            },
            {
                key: 'strategy',
                label: currentTranslations['aiPromptsStrategy'] || 'Build or Review Strategy',
                recommended: isStrategyDoc,
                badge: fileLang === 'vi' ? 'Chiến Lược' : 'Strategy',
                badgeType: 'suggest'
            },
            {
                key: 'review',
                label: currentTranslations['aiPromptsReview'] || 'Review & Update Docs',
                recommended: !needsFrontmatter && !hasHeadingIssues && !isStrategyDoc,
                badge: fileLang === 'vi' ? 'Đề Xuất' : 'Recommend',
                badgeType: 'suggest'
            }
        ];

        // Bubble up recommended prompts
        promptItems.sort((a, b) => (b.recommended ? 1 : 0) - (a.recommended ? 1 : 0));

        let dropdownHtml = '';
        promptItems.forEach(item => {
            let badgeHtml = '';
            if (item.recommended) {
                badgeHtml = `<span class="prompt-badge ${item.badgeType}">${item.badge}</span>`;
            }
            dropdownHtml += `
                    <div class="prompt-item" onclick="copyAiPrompt('${item.key}')">
                        <span style="display: flex; align-items: center; gap: 4px;">
                            <span>${item.label}</span>
                            ${badgeHtml}
                        </span>
                        <i data-lucide="copy"></i>
                    </div>`;
        });

        const aiPromptsTitle = currentTranslations['aiPromptsTitle'] || 'AI Prompt Suggestions';
        const aiPromptsHtml = `
            <div class="ai-prompts-container">
                <button class="ai-prompts-toggle-btn" id="ai-prompts-toggle-btn" onclick="toggleAiPromptsDropdown()">
                    <span style="display: flex; align-items: center; gap: 6px;">
                        <i data-lucide="sparkles" style="width: 14px; height: 14px; fill: currentColor;"></i>
                        ${aiPromptsTitle}
                    </span>
                    <i data-lucide="chevron-down" id="ai-prompts-chevron" style="width: 14px; height: 14px; transition: transform 0.2s;"></i>
                </button>
                <div class="ai-prompts-dropdown" id="ai-prompts-dropdown">
                    ${dropdownHtml}
                </div>
            </div>`;

        const relativeSourcePath = path.relative(process.cwd(), sourceFile);
        const absoluteSourcePath = path.resolve(sourceFile);
        const docCleanName = getMarkdownCleanName(sourceFile);
        
        const sidebarHtml = ''; // Sub-pages run in App Shell iframe and do not need individual sidebars
        
        const now = new Date();
        const renderTime = now.toLocaleString(fileLang === 'vi' ? 'vi-VN' : 'en-US', {
            year: 'numeric',
            month: '2-digit',
            day: '2-digit',
            hour: '2-digit',
            minute: '2-digit',
            second: '2-digit'
        });
        
        // Apply i18n translation replacements
        let html = template;
        html = html.replaceAll('/* WORKSPACE_LANG */', fileLang);
        
        for (const key in currentTranslations) {
            html = html.replaceAll(`/* TRANSLATE:${key} */`, currentTranslations[key]);
        }
        
        const readmeVirtualPath = getVirtualRelativePath(path.join(rootDir, 'README.md'), rootDir).replace(/\.md$/, '.html');
        const relativeReadmeFromTarget = path.relative(path.dirname(targetFile), path.join(rootOutputDir, readmeVirtualPath));
        
        // Auto-detect language of README
        let readmeLangPath = 'README.html';
        if (fileLang === 'en' && fs.existsSync(path.join(rootOutputDir, 'en', 'README.html'))) {
            readmeLangPath = 'en/README.html';
        } else if (fileLang === 'vi' && fs.existsSync(path.join(rootOutputDir, 'vi', 'README.html'))) {
            readmeLangPath = 'vi/README.html';
        }

        const relativeReadmeUrl = relativeReadmeFromTarget.replace(/\\/g, '/');
        
        const relativeSearchIndexFromTarget = path.relative(path.dirname(targetFile), path.join(rootOutputDir, 'search-index.js'));
        const relativeSearchIndexUrl = relativeSearchIndexFromTarget.replace(/\\/g, '/');
        
        // Replace structural data placeholders
        html = html
            .replaceAll('/* MARKDOWN_CONTENT_PLACEHOLDER */', escapedMarkdown)
            .replaceAll('/* AUDIT_DETAILS_PLACEHOLDER */', escapedAuditDetails)
            .replaceAll('/* SOURCE_MD_PATH */', relativeSourcePath)
            .replaceAll('/* SOURCE_MD_ABS_PATH */', absoluteSourcePath)
            .replaceAll('/* CURRENT_DOC_NAME */', docCleanName)
            .replaceAll('/* README_RELATIVE_URL */', relativeReadmeUrl)
            .replaceAll('/* SEARCH_INDEX_RELATIVE_URL */', relativeSearchIndexUrl)
            .replaceAll('/* RENDER_TIME */', renderTime)
            .replaceAll('/* KERNEL_VERSION */', kernelVersion)
            .replaceAll('<!-- DOC_METADATA_PLACEHOLDER -->', metadataHtml)
            .replaceAll('<!-- STATS_PANEL_PLACEHOLDER -->', statsPanelHtml)
            .replaceAll('<!-- DRIFT_AUDIT_PLACEHOLDER -->', driftAuditHtml)
            .replaceAll('<!-- AI_PROMPTS_PLACEHOLDER -->', aiPromptsHtml)
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
    const readmePath = path.join(srcDir, 'README.md');
    const folderOrderList = getFolderOrderFromReadme(readmePath);
    
    const projectDir = path.dirname(srcDir);
    const sysdesignsDir = path.join(projectDir, 'artifacts', 'sysdesigns');
    const specsDir = path.join(projectDir, 'artifacts', 'specs');
    const writingsDir = fs.existsSync(path.join(projectDir, 'writings'))
        ? path.join(projectDir, 'writings')
        : path.join(projectDir, 'artifacts', 'writings');

    // Create a virtualRoot as a parent node
    const virtualRoot = {
        name: 'Root',
        path: projectDir,
        isDirectory: true,
        children: []
    };

    // 1. Add sysdesigns branch
    if (fs.existsSync(sysdesignsDir)) {
        const sysTree = buildTree(sysdesignsDir, sysdesignsDir);
        if (sysTree.children && sysTree.children.length > 0) {
            sysTree.name = 'sysdesigns';
            sysTree.order = 10;
            sysTree.hideOrder = true;
            virtualRoot.children.push(sysTree);
        }
    }

    // 2. Add specs branch
    if (fs.existsSync(specsDir)) {
        const specsTree = buildTree(specsDir, specsDir);
        if (specsTree.children && specsTree.children.length > 0) {
            specsTree.name = 'specs';
            specsTree.order = 20;
            specsTree.hideOrder = true;
            virtualRoot.children.push(specsTree);
        }
    }

    // 3. Add docs branch
    const docsTree = buildTree(srcDir, srcDir, folderOrderList);
    docsTree.name = 'docs';
    docsTree.order = 30;
    docsTree.hideOrder = true;
    virtualRoot.children.push(docsTree);

    // 4. Add writings branch
    if (fs.existsSync(writingsDir)) {
        const writingsTree = buildTree(writingsDir, writingsDir);
        if (writingsTree.children && writingsTree.children.length > 0) {
            writingsTree.name = 'writings';
            writingsTree.order = 40;
            writingsTree.hideOrder = true;
            virtualRoot.children.push(writingsTree);
        }
    }

    // Sort virtual subtrees
    virtualRoot.children.sort((a, b) => {
        const orderA = a.order !== undefined ? a.order : 999999;
        const orderB = b.order !== undefined ? b.order : 999999;
        return orderA - orderB;
    });

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
    collectMdFiles(virtualRoot);
    
    // Load Graph data first to support dynamic node referencing in renderSingleFile
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
    hasGraph = false;
    
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
            blastRadii[nodeId] = visited.size - 1;
            return blastRadii[nodeId];
        };
    }

    // Helper to map project-relative paths (from graph) to virtual relative paths (used by dashboard render)
    function projectPathToVirtualRelativePath(projPath) {
        const normalized = projPath.replace(/\\/g, '/');
        if (normalized.startsWith('artifacts/sysdesigns/')) {
            return normalized.replace('artifacts/sysdesigns/', 'sysdesigns/');
        } else if (normalized.startsWith('artifacts/specs/')) {
            return normalized.replace('artifacts/specs/', 'specs/');
        } else if (normalized.startsWith('artifacts/writings/')) {
            return normalized.replace('artifacts/writings/', 'writings/');
        } else if (normalized.startsWith('artifacts/')) {
            return normalized.replace('artifacts/', '');
        }
        return normalized;
    }

    // Reset global maps
    anchorToCodeNodesMap = {};
    const nodeToAnchorsMap = {}; // Maps node.id to Set of relativeMdPath#anchorId
    nodeToCodeDocsMap = {};
    specToDocsMap = {};
    docToSpecsMap = {};
    
    // Maps anchorId to its virtual relative markdown file path
    const definedAnchorsMap = {};
    let docsWithAnchors = 0;
    
    for (const mdFile of allMdFiles) {
        try {
            const content = fs.readFileSync(mdFile, 'utf8');
            let hasAnchor = false;
            
            const nodeRegex = /<span\s+id=["'](csa-[a-zA-Z0-9.:\/_-]+)["'][^>]*><\/span>/g;
            let match;
            const relativeMdPath = getVirtualRelativePath(mdFile, srcDir).replace(/\\/g, '/');
            
            while ((match = nodeRegex.exec(content)) !== null) {
                const anchorId = match[1];
                if (anchorId.includes('...')) {
                    continue;
                }
                hasAnchor = true;
                definedAnchorsMap[anchorId] = relativeMdPath;
            }
            
            // Parse data-csa-inherits (Transitive CSA link)
            const inheritRegex = /<span\s+data-csa-inherits=["'](csa-[a-zA-Z0-9.:\/_,\s-]+)["'][^>]*><\/span>/g;
            let inheritMatch;
            while ((inheritMatch = inheritRegex.exec(content)) !== null) {
                const inheritsStr = inheritMatch[1];
                const parts = inheritsStr.split(',').map(p => p.trim());
                parts.forEach(part => {
                    if (part.includes('...')) {
                        return;
                    }
                    if (!specToDocsMap[part]) {
                        specToDocsMap[part] = new Set();
                    }
                    specToDocsMap[part].add(relativeMdPath);
                    
                    if (!docToSpecsMap[relativeMdPath]) {
                        docToSpecsMap[relativeMdPath] = new Set();
                    }
                    docToSpecsMap[relativeMdPath].add(part);
                });
            }
            
            if (hasAnchor) {
                docsWithAnchors++;
            }
        } catch (e) {
            console.warn(`Warning: Failed to parse anchors for mapping in ${mdFile}:`, e.message);
        }
    }

    // Populate maps from graph relationships
    if (hasGraph && fs.existsSync(relationsPath)) {
        try {
            const relLines = fs.readFileSync(relationsPath, 'utf8').split('\n');
            for (const line of relLines) {
                if (line.trim()) {
                    const rel = JSON.parse(line);
                    if (rel.relation === 'DOCUMENTED_BY' && rel.sourceId && rel.targetId) {
                        const sourceId = rel.sourceId;
                        const targetId = rel.targetId.startsWith('#') ? rel.targetId.substring(1) : rel.targetId;
                        
                        const targetNode = graphNodesMap[targetId];
                        if (targetNode) {
                            let virtualPath = definedAnchorsMap[targetId];
                            if (!virtualPath) {
                                virtualPath = projectPathToVirtualRelativePath(targetNode.filePath);
                            }
                            
                            const anchorLink = `${virtualPath}#${targetId}`;
                            
                            if (!nodeToAnchorsMap[sourceId]) {
                                nodeToAnchorsMap[sourceId] = new Set();
                            }
                            nodeToAnchorsMap[sourceId].add(anchorLink);
                            
                            if (!nodeToCodeDocsMap[sourceId]) {
                                nodeToCodeDocsMap[sourceId] = [];
                            }
                            nodeToCodeDocsMap[sourceId].push(anchorLink);
                            
                            const codeNode = graphNodesMap[sourceId];
                            if (codeNode) {
                                if (!anchorToCodeNodesMap[targetId]) {
                                    anchorToCodeNodesMap[targetId] = [];
                                }
                                if (!anchorToCodeNodesMap[targetId].some(n => n.id === codeNode.id)) {
                                    anchorToCodeNodesMap[targetId].push(codeNode);
                                }
                            }
                        }
                    }
                    if (rel.relation === 'DOCUMENTS' && rel.sourceId && rel.targetId) {
                        const docPath = rel.sourceId.replace(/\\/g, '/');
                        const specId = rel.targetId.startsWith('#') ? rel.targetId.substring(1) : rel.targetId;
                        
                        if (!specToDocsMap[specId]) {
                            specToDocsMap[specId] = new Set();
                        }
                        specToDocsMap[specId].add(docPath);
                        
                        if (!docToSpecsMap[docPath]) {
                            docToSpecsMap[docPath] = new Set();
                        }
                        docToSpecsMap[docPath].add(specId);
                    }
                }
            }
        } catch (e) {
            console.warn('Warning: Failed to parse relations for anchors mapping:', e.message);
        }
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
    let enrichableNodes = [];
    let linkedNodes = [];
    let godNodes = [];
    let staleNodes = [];
    let weightedHealthScore = 100;
    let codeLinkedNodes = [];
    let documentedGodNodesCount = 0;
    let codeLinkedGodNodesCount = 0;
    
    if (hasGraph) {
        enrichableNodes = graphNodes.filter(node => {
            const isTest = node.filePath && (node.filePath.startsWith('tests/') || node.filePath.includes('.test.'));
            const isSpecAnchor = node.type === 'spec_anchor';
            const excluded = isExcluded(node.filePath);
            return !isTest && !isSpecAnchor && !excluded;
        });
        
        linkedNodes = enrichableNodes.filter(node => {
            const hasScanned = nodeToAnchorsMap[node.id] && nodeToAnchorsMap[node.id].size > 0;
            return hasScanned;
        });
        const enrichedNodes = enrichableNodes.filter(node => node.semantic && node.semantic.summary && node.semantic.summary.trim() !== '');
        
        const godThreshold = projectCalibration.weights.god_node_degree_threshold ?? 20;
        godNodes = enrichableNodes.filter(node => node.degree >= godThreshold);
        const documentedGodNodes = godNodes.filter(node => {
            const hasScanned = nodeToAnchorsMap[node.id] && nodeToAnchorsMap[node.id].size > 0;
            return hasScanned;
        });
        staleNodes = enrichableNodes.filter(node => node.staleSince && node.staleSince !== null);
        
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

        existingSpecAnchorIds.clear();
        graphNodes.forEach(n => {
            if (n.type === 'spec_anchor') {
                existingSpecAnchorIds.add(n.id);
                if (n.id.includes('#')) {
                    existingSpecAnchorIds.add(n.id.split('#')[1]);
                }
            }
        });

        processedNodesData = enrichableNodes.map(node => {
            const godThreshold = projectCalibration.weights.god_node_degree_threshold ?? 20;
            const isCritical = node.degree >= godThreshold;
            
            let weight = projectCalibration.weights.medium ?? 2.0;
            let weightedClass = 'medium';
            
            if (isCritical) {
                weight = projectCalibration.weights.critical ?? 5.0;
                weightedClass = 'critical';
            } else if (node.type === 'variable') {
                weight = projectCalibration.weights.low ?? 0.5;
                weightedClass = 'low';
            }
            
            const finalDocAnchors = nodeToAnchorsMap[node.id] ? Array.from(nodeToAnchorsMap[node.id]) : [];
            
            const isLinked = finalDocAnchors.length > 0;
            const isEnriched = node.semantic && node.semantic.summary && node.semantic.summary.trim() !== '';
            
            // Parse @para-doc comments from source code
            const absoluteFilePath = path.resolve(projectDir, 'repo', node.filePath || '');
            let codeDocs = [];
            if (hasGraph && nodeToCodeDocsMap[node.id]) {
                codeDocs = nodeToCodeDocsMap[node.id];
            } else {
                const fileComments = getParaDocCommentsForFile(absoluteFilePath);
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
            }
            const hasCodeDoc = codeDocs.length > 0;

            totalWeight += weight;
            let completionFactor = 0;
            if (isLinked && hasCodeDoc) {
                completionFactor = 1.0;
            } else if (isLinked || hasCodeDoc) {
                completionFactor = 0.5;
            }
            linkedWeight += weight * completionFactor;
            
            let specId = '';
            if (codeDocs && codeDocs.length > 0) {
                const parts = codeDocs[0].split('#');
                specId = parts[parts.length - 1];
            } else if (finalDocAnchors && finalDocAnchors.length > 0) {
                const parts = finalDocAnchors[0].split('#');
                specId = parts[parts.length - 1];
            }

            const docsList = specId ? Array.from(specToDocsMap[specId] || []) : [];
            const isDocLinked = docsList.length > 0;
            const isSpecLinked = specId ? existingSpecAnchorIds.has(specId) : false;

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
                docAnchors: finalDocAnchors,
                codeDocs: codeDocs,
                summary: (node.semantic && node.semantic.summary) || '',
                specId: specId,
                isSpecLinked: isSpecLinked,
                isDocLinked: isDocLinked,
                linkedDocsList: docsList
            };
        });
        
        weightedHealthScore = totalWeight > 0 ? (linkedWeight / totalWeight) * 100 : 0;
        codeLinkedNodes = enrichableNodes.filter(node => {
            const absPath = path.resolve(projectDir, 'repo', node.filePath || '');
            const fileComments = getParaDocCommentsForFile(absPath);
            if (node.type === 'file') {
                return fileComments.some(c => c.line <= 5);
            } else {
                return fileComments.some(c => c.line >= (node.startLine || 1) - 4 && c.line <= (node.startLine || 1));
            }
        });
        documentedGodNodesCount = godNodes.filter(node => {
            const hasScanned = nodeToAnchorsMap[node.id] && nodeToAnchorsMap[node.id].size > 0;
            return hasScanned;
        }).length;
        codeLinkedGodNodesCount = godNodes.filter(node => {
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

        let danglingLinksCount = 0;
        processedNodesData.forEach(node => {
            node.danglingDocs = [];
            if (node.codeDocs && node.codeDocs.length > 0) {
                node.codeDocs.forEach(doc => {
                    if (!doc.includes('#')) return; // Bỏ qua liên kết file toàn cục không có anchor
                    const parts = doc.split('#');
                    const anchorId = parts[1];
                    if (!existingSpecAnchorIds.has(anchorId) && !existingSpecAnchorIds.has(doc)) {
                        danglingLinksCount++;
                        node.danglingDocs.push(doc);
                    }
                });
            }
        });
        dashboardStats.danglingLinksCount = danglingLinksCount;
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
        const relPath = getVirtualRelativePath(mdFile, srcDir);
        // Detect file language
        let fileLang = workspaceLang;
        const normalizedPath = mdFile.replace(/\\/g, '/');
        if (normalizedPath.includes('/en/')) {
            fileLang = 'en';
        } else if (normalizedPath.includes('/vi/')) {
            fileLang = 'vi';
        }
        const title = getMarkdownCleanName(mdFile);
        let alignmentStats = null;
        
        let mdContent = '';
        try {
            mdContent = fs.readFileSync(mdFile, 'utf8');
        } catch (e) {
            continue;
        }
        
        const fileSpans = new Set();
        const spanRegex = /<span\s+id=["'](csa-[a-zA-Z0-9.:\/_-]+)["'][^>]*><\/span>/g;
        let spanMatch;
        while ((spanMatch = spanRegex.exec(mdContent)) !== null) {
            const anchorId = spanMatch[1];
            if (!anchorId.includes('...')) {
                fileSpans.add(anchorId);
            }
        }

        const headers = [];
        const headerRegex = /^(#{1,6})\s+(.+)$/gm;
        let hMatch;
        while ((hMatch = headerRegex.exec(mdContent)) !== null) {
            headers.push(hMatch[2].trim());
        }
        
        const matchesDoc = (anchor) => {
            const cleanAnchor = anchor.split('#')[0].replace(/\\/g, '/').toLowerCase();
            const cleanMd = mdFile.replace(/\\/g, '/').toLowerCase();
            
            const getRelativeSignature = (p) => {
                for (const marker of ['/docs/', '/artifacts/', '/writings/']) {
                    const idx = p.indexOf(marker);
                    if (idx !== -1) return p.substring(idx + 1);
                }
                if (p.startsWith('docs/') || p.startsWith('artifacts/') || p.startsWith('writings/')) {
                    return p;
                }
                return path.basename(p);
            };

            const anchorSig = getRelativeSignature(cleanAnchor);
            const mdSig = getRelativeSignature(cleanMd);
            
            if (!anchorSig.includes('/') || !mdSig.includes('/')) {
                return path.basename(anchorSig) === path.basename(mdSig);
            }
            return anchorSig === mdSig;
        };

        const isSpecFile = relPath.startsWith('specs/') || relPath.includes('/specs/') || fileSpans.size > 0;
        const docInherits = docToSpecsMap[relPath];
        const hasInherits = docInherits && docInherits.size > 0;

        const docNodes = processedNodesData.filter(node => {
            return node.docAnchors.some(matchesDoc) || node.codeDocs.some(matchesDoc);
        });
        
        if (docNodes.length === 0 && !isSpecFile && !hasInherits) continue;
        
        // Build Mermaid diagram
        let mermaid = 'graph TD\n';
        if (docNodes.length > 0) {
            const nodeIdsInDoc = new Set(docNodes.map(n => n.id));
            
            docNodes.forEach(n => {
                const cleanId = n.id.replace(/[^a-zA-Z0-9]/g, '_');
                const cleanName = n.name.replace(/["']/g, '');
                mermaid += `    ${cleanId}["${n.type}: ${cleanName}"]\n`;
            });
            
            for (const targetId in impactAdjacencyList) {
                if (nodeIdsInDoc.has(targetId)) {
                    impactAdjacencyList[targetId].forEach(sourceId => {
                        if (nodeIdsInDoc.has(sourceId)) {
                            const srcClean = sourceId.replace(/[^a-zA-Z0-9]/g, '_');
                            const tgtClean = targetId.replace(/[^a-zA-Z0-9]/g, '_');
                            mermaid += `    ${srcClean} --> ${tgtClean}\n`;
                        }
                    });
                }
            }
        } else {
            mermaid += `    no_nodes["${fileLang === 'vi' ? 'Không có cấu phần mã liên kết trực tiếp' : 'No directly linked code components'}"]\n`;
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
                    
                    if (matchesDoc(anchorFile)) {
                        const isMatch = fileSpans.has(anchorName) || (anchorName.startsWith('csa-') ? fileSpans.has(anchorName.substring(4)) : fileSpans.has('csa-' + anchorName)) || isLooseAnchorMatch(anchorName, headers);
                        if (!isMatch) {
                            auditReports.push({
                                severity: 'medium',
                                title: fileLang === 'vi' ? `Neo liên kết hỏng trong \`${node.name}\`` : `Broken Anchor Link in Node \`${node.name}\``,
                                description: fileLang === 'vi' 
                                    ? `Cấu phần liên kết tới neo \`#${anchorName}\` nhưng tiêu đề này không tồn tại trong tài liệu spec.`
                                    : `Node linked to anchor \`#${anchorName}\` but this header was not found in the spec file.`,
                                solution: fileLang === 'vi'
                                    ? `Thêm thẻ neo \`<span id="${anchorName.startsWith('csa-') ? anchorName : 'csa-' + anchorName}"></span>\` vào vị trí phù hợp trong tài liệu, hoặc cập nhật chú thích neo trong code để tham chiếu tới một neo tiếng Anh hợp lệ.`
                                    : `Add the anchor tag \`<span id="${anchorName.startsWith('csa-') ? anchorName : 'csa-' + anchorName}"></span>\` to the matching section, or update the code comment to link to a valid English anchor.`
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
                                title: fileLang === 'vi' ? 'GAP: Vi phạm quy tắc Underpayment trong đối soát hàng loạt' : 'GAP: Underpayment violation in batch reconciliation',
                                description: fileLang === 'vi'
                                    ? `Trong hàm \`applyRulesToExistingPayments\`, hệ thống tự động gán status đơn hàng thành \`'paid'\` khi đối soát hàng loạt mà không check điều kiện thanh toán thiếu.`
                                    : `In \`applyRulesToExistingPayments\`, the system sets invoice status to \`'paid'\` directly without verifying if the payment amount is sufficient.`,
                                solution: fileLang === 'vi'
                                    ? `Sửa logic gán status thành: \`const status = payment.amount >= invoice.amount ? 'paid' : 'partially_paid';\`.`
                                    : `Modify the status assignment logic to check: \`const status = payment.amount >= invoice.amount ? 'paid' : 'partially_paid';\`.`
                            });
                        }
                    }
                    if (!codeContent.includes("sum(payments.amount)") && !codeContent.includes("sum(payment.amount)")) {
                        auditReports.push({
                            severity: 'medium',
                            title: fileLang === 'vi' ? 'GAP: Thiếu cơ chế cộng dồn thanh toán bổ sung' : 'GAP: Missing payment union logic',
                            description: fileLang === 'vi'
                                ? `Hệ thống chưa có logic cộng dồn tổng tiền các payment để kích hoạt hóa đơn thanh toán thiếu sang paid.`
                                : `The system lacks logic to sum up partial payments to automatically transition underpaid invoices to paid.`,
                            solution: fileLang === 'vi'
                                ? `Viết thêm hàm helper \`checkAndUnionPartialPayments(db, invoiceId)\` chạy khi gán payment.`
                                : `Implement helper function \`checkAndUnionPartialPayments(db, invoiceId)\` to check total payment amount.`
                        });
                    }
                } catch (err) {}
            }
        }
        
        // Transitive CSA Drift & Gap Audits
        if (isSpecFile) {
            // Audit defined spec anchors
            fileSpans.forEach(specId => {
                // 1. Spec-Code Gap
                let codeNodes = anchorToCodeNodesMap[specId] || [];
                if (codeNodes.length === 0) {
                    const matchingKey = Object.keys(anchorToCodeNodesMap).find(k => k === specId || k.endsWith('#' + specId));
                    if (matchingKey) {
                        codeNodes = anchorToCodeNodesMap[matchingKey];
                    }
                }
                
                if (codeNodes.length === 0) {
                    auditReports.push({
                        severity: 'medium',
                        anchorId: specId,
                        title: fileLang === 'vi' ? `GAP: Spec chưa có mã nguồn hiện thực` : `GAP: Spec unimplemented by source code`,
                        description: fileLang === 'vi'
                            ? `Đặc tả \`${specId}\` đã được định nghĩa nhưng chưa được liên kết đến bất kỳ hàm, lớp hay tệp code nào trong mã nguồn.`
                            : `Specification anchor \`${specId}\` is defined but has no implementation binding in source code.`,
                        solution: fileLang === 'vi'
                            ? `Thêm chú thích comment \`// @para-doc [${specId}]\` trước hàm hoặc class hiện thực đặc tả này.`
                            : `Add comment \`// @para-doc [${specId}]\` directly above the function or class implementing this spec.`
                    });
                }
                
                // 2. Spec-Docs Gap (Transitive documentation gap)
                let docsList = specToDocsMap[specId] || new Set();
                if (docsList.size === 0) {
                    const matchingKey = Object.keys(specToDocsMap).find(k => k === specId || k.endsWith('#' + specId));
                    if (matchingKey) {
                        docsList = specToDocsMap[matchingKey];
                    }
                }
                
                const otherDocsList = Array.from(docsList).filter(p => p !== relPath);
                if (otherDocsList.length === 0) {
                    auditReports.push({
                        severity: 'low',
                        anchorId: specId,
                        title: fileLang === 'vi' ? `GAP: Spec chưa được tài liệu hóa` : `GAP: Spec undocumented in guides`,
                        description: fileLang === 'vi'
                            ? `Đặc tả \`${specId}\` đã được định nghĩa nhưng chưa được tài liệu hóa hay giải thích trong bất kỳ tệp hướng dẫn nào thuộc \`docs/\` hoặc kế hoạch \`plans/\`.`
                            : `Specification \`${specId}\` is defined but has not been documented in any markdown user guides under \`docs/\` or plans under \`plans/\`.`,
                        solution: fileLang === 'vi'
                            ? `Tạo tệp tài liệu hướng dẫn trong \`docs/\` và chèn thẻ \`<span data-csa-inherits="${specId}"></span>\`.`
                            : `Create a markdown document under \`docs/\` and insert \`<span data-csa-inherits="${specId}"></span>\`.`
                    });
                }
            });
        }
        
        // If this file inherits any spec anchors (acts as a doc or plan)
        if (docInherits && docInherits.size > 0) {
            docInherits.forEach(inheritId => {
                // 3. Dangling Inherits Link
                if (!definedAnchorsMap[inheritId]) {
                    auditReports.push({
                        severity: 'high',
                        anchorId: inheritId,
                        title: fileLang === 'vi' ? `Lỗi neo inherits hỏng (Dangling Inherits)` : `Dangling Inherits Reference`,
                        description: fileLang === 'vi'
                            ? `Tài liệu khai báo thừa kế đặc tả \`data-csa-inherits="${inheritId}"\` nhưng Spec ID này không tồn tại trong hệ thống.`
                            : `Document inherits spec \`data-csa-inherits="${inheritId}"\` but this Spec ID does not exist in any spec files.`,
                        solution: fileLang === 'vi'
                            ? `Kiểm tra lại chính tả Spec ID, hoặc định nghĩa Spec Anchor này trong tệp spec tương ứng.`
                            : `Double check the Spec ID spelling, or define this Spec Anchor inside the corresponding spec file.`
                    });
                } else {
                    // 4. Outdated Doc (Timestamp check)
                    const specRelPath = definedAnchorsMap[inheritId];
                    if (specRelPath) {
                        let specAbsPath = path.resolve(projectDir, specRelPath);
                        if (!fs.existsSync(specAbsPath)) {
                            if (specRelPath.startsWith('specs/')) {
                                specAbsPath = path.resolve(projectDir, 'artifacts', specRelPath);
                            }
                        }
                        if (fs.existsSync(specAbsPath)) {
                            const docMtime = fs.statSync(mdFile).mtimeMs;
                            const specMtime = fs.statSync(specAbsPath).mtimeMs;
                            
                            if (specMtime > docMtime) {
                                auditReports.push({
                                    severity: 'medium',
                                    anchorId: inheritId,
                                    title: fileLang === 'vi' ? `Tài liệu bị cũ so với đặc tả (Outdated Docs)` : `Outdated Documentation`,
                                    description: fileLang === 'vi'
                                        ? `Tệp đặc tả \`${specRelPath}\` có thay đổi mới hơn tệp tài liệu này (neo thừa kế \`${inheritId}\`). Bản giải thích có thể đã lỗi thời.`
                                        : `The spec file \`${specRelPath}\` is newer than this document (inherited anchor \`${inheritId}\`). The documentation may be outdated.`,
                                    solution: fileLang === 'vi'
                                        ? `Xem lại các thay đổi trong \`${specRelPath}\` và cập nhật lại nội dung hướng dẫn cho khớp.`
                                        : `Review recent changes in \`${specRelPath}\` and update the guide content accordingly.`
                                });
                            }
                        }
                    }
                }
            });
        }


        // Always calculate statistical indices for the document
        const stats = {
            totalEntities: docNodes.length,
            doubleBound: 0,
            docsToCode: 0,
            codeToDocs: 0,
            withHeading: 0,
            typeCounts: {},
            topHeadings: []
        };
        const headingFreq = {};
        docNodes.forEach(n => {
            const getHeadingsFromAnchors = (anchors) => {
                return anchors
                    .filter(a => matchesDoc(a) && a.includes('#'))
                    .map(a => '#' + a.split('#')[1])
                    .filter((v, i, arr) => arr.indexOf(v) === i); // deduplicate
            };
            
            const docAnchorHeadings = getHeadingsFromAnchors(n.docAnchors);
            const codeDocHeadings = getHeadingsFromAnchors(n.codeDocs);
            
            const hasDocAnchor = docAnchorHeadings.length > 0 || n.docAnchors.some(a => matchesDoc(a));
            const hasCodeDoc = codeDocHeadings.length > 0 || n.codeDocs.some(a => {
                if (!a.includes('#')) {
                    // Shortened anchor ID match
                    const cleanA = a.startsWith('csa-') ? a.substring(4) : a;
                    return a === n.id || cleanA === n.name || n.id.endsWith('::' + cleanA);
                }
                return matchesDoc(a);
            });
            
            if (hasDocAnchor && hasCodeDoc) {
                stats.doubleBound++;
            }
            if (hasDocAnchor) {
                stats.docsToCode++;
            }
            if (hasCodeDoc) {
                stats.codeToDocs++;
            }
            
            const allHeadings = [...new Set([...docAnchorHeadings, ...codeDocHeadings])];
            if (allHeadings.length > 0) {
                stats.withHeading++;
                allHeadings.forEach(h => {
                    headingFreq[h] = (headingFreq[h] || 0) + 1;
                });
            }
            
            stats.typeCounts[n.type] = (stats.typeCounts[n.type] || 0) + 1;
        });
        
        // Convert headingFreq to sorted array
        const sortedHeadings = Object.entries(headingFreq)
            .map(([heading, count]) => ({ heading, count }))
            .sort((a, b) => b.count - a.count);
        
        stats.topHeadings = sortedHeadings.slice(0, 5);
        alignmentStats = stats;
        
        // Additional Drift Audit: Code→Docs orphan check (codeDocs pointing to non-existent headings)
        docNodes.forEach(node => {
            node.codeDocs.forEach(codeDocStr => {
                if (codeDocStr.includes('#')) {
                    const parts = codeDocStr.split('#');
                    const codeDocFile = parts[0];
                    const codeDocAnchor = parts[1];
                    
                    const codeDocBase = path.basename(codeDocFile).toLowerCase();
                    const currentFileBase = path.basename(mdFile).toLowerCase();
                    if (codeDocBase === currentFileBase) {
                        const isMatch = fileSpans.has(codeDocAnchor) || (codeDocAnchor.startsWith('csa-') ? fileSpans.has(codeDocAnchor.substring(4)) : fileSpans.has('csa-' + codeDocAnchor)) || isLooseAnchorMatch(codeDocAnchor, headers);
                        if (!isMatch) {
                            // Avoid duplicate if same anchor already reported from docAnchors check
                            const isDuplicate = auditReports.some(r => r.description && r.description.includes(codeDocAnchor));
                            if (!isDuplicate) {
                                auditReports.push({
                                    severity: 'medium',
                                    title: fileLang === 'vi' 
                                        ? `Neo @para-doc hỏng từ \`${node.name}\`` 
                                        : `Broken @para-doc link from \`${node.name}\``,
                                    description: fileLang === 'vi' 
                                        ? `Chú thích @para-doc trong code trỏ tới neo \`#${codeDocAnchor}\` nhưng heading này không tồn tại trong tài liệu.`
                                        : `@para-doc comment in code points to anchor \`#${codeDocAnchor}\` but this heading was not found in the document.`,
                                    solution: fileLang === 'vi'
                                        ? `Cập nhật chú thích @para-doc trong \`${node.filePath}\` hoặc thêm heading phù hợp vào tài liệu.`
                                        : `Update @para-doc comment in \`${node.filePath}\` or add the matching heading to the document.`
                                });
                            }
                        }
                    }
                } else {
                    // Shortened anchor ID match check
                    const currentFileRel = path.relative(rootDir, mdFile).replace(/\\/g, '/');
                    const matchesDoc = node.docAnchors.some(a => {
                        const relA = a.replace(/\\/g, '/');
                        return relA === currentFileRel || relA.endsWith('/' + currentFileRel) || currentFileRel.endsWith('/' + relA);
                    });
                    
                    if (matchesDoc) {
                        const cleanDocStr = codeDocStr.startsWith('csa-') ? codeDocStr.substring(4) : codeDocStr;
                        const hasAnchorInDoc = fileSpans.has(codeDocStr) || (codeDocStr.startsWith('csa-') ? fileSpans.has(codeDocStr.substring(4)) : fileSpans.has('csa-' + codeDocStr)) || linkedNodeIds.some(id => {
                            const cleanId = id.startsWith('csa-') ? id.substring(4) : id;
                            return cleanId === cleanDocStr;
                        });
                        
                        if (!hasAnchorInDoc) {
                            const isDuplicate = auditReports.some(r => r.description && r.description.includes(codeDocStr));
                            if (!isDuplicate) {
                                auditReports.push({
                                    severity: 'medium',
                                    title: fileLang === 'vi' 
                                        ? `Neo @para-doc hỏng từ \`${node.name}\`` 
                                        : `Broken @para-doc link from \`${node.name}\``,
                                    description: fileLang === 'vi' 
                                        ? `Chú thích @para-doc trong code trỏ tới neo \`${codeDocStr}\` nhưng thẻ neo này không tồn tại trong tài liệu.`
                                        : `@para-doc comment in code points to anchor \`${codeDocStr}\` but this anchor was not found in the document.`,
                                    solution: fileLang === 'vi'
                                        ? `Thêm thẻ neo \`<span id="${codeDocStr.startsWith('csa-') ? codeDocStr : 'csa-' + codeDocStr}"></span>\` vào tài liệu.`
                                        : `Add the anchor tag \`<span id="${codeDocStr.startsWith('csa-') ? codeDocStr : 'csa-' + codeDocStr}"></span>\` to the document.`
                                });
                            }
                        }
                    }
                }
            });
        });
        
        alignmentData[relPath] = {
            title: title,
            mermaid: mermaid,
            alignmentStats: alignmentStats,
            auditReports: auditReports
        };
    }
    
    // Calculate server-side healthPct (Documentation Freshness/Sync Rate)
    const staleDocPaths = new Set();
    staleNodes.forEach(node => {
        const anchors = nodeToAnchorsMap[node.id] ? Array.from(nodeToAnchorsMap[node.id]) : [];
        anchors.forEach(a => {
            const docPath = a.split('#')[0];
            let cleanDocPath = docPath.replace(/\\/g, '/');
            if (cleanDocPath.startsWith('docs/')) {
                cleanDocPath = cleanDocPath.substring(5);
            } else if (cleanDocPath.startsWith('artifacts/sysdesigns/')) {
                cleanDocPath = 'sysdesigns/' + cleanDocPath.substring(21);
            } else if (cleanDocPath.startsWith('artifacts/specs/')) {
                cleanDocPath = 'specs/' + cleanDocPath.substring(16);
            }
            staleDocPaths.add(cleanDocPath);
        });
    });

    const unhealthyDocPaths = new Set(staleDocPaths);
    for (const relPath in alignmentData) {
        const reports = alignmentData[relPath].auditReports || [];
        if (reports.length > 0) {
            unhealthyDocPaths.add(relPath);
        }
    }

    const activeDocsCount = allMdFiles.length;
    const unhealthyDocsCount = Array.from(unhealthyDocPaths).filter(p => {
        return allMdFiles.some(f => getVirtualRelativePath(f, srcDir) === p);
    }).length;

    const serverHealthPct = activeDocsCount > 0 ? ((activeDocsCount - unhealthyDocsCount) / activeDocsCount) * 100 : 100;
    const overallHealthScore = weightedHealthScore * (serverHealthPct / 100);

    dashboardStats.overallHealthScore = overallHealthScore;
    dashboardStats.weightedCoverage = weightedHealthScore;
    dashboardStats.syncRate = serverHealthPct;

    // Auto-update README.md with new Graph Traceability stats
    if (fs.existsSync(readmePath)) {
        try {
            let readmeContent = fs.readFileSync(readmePath, 'utf8');
            const traceabilityHeader = '## Graph Traceability';
            const updatedDate = new Date().toISOString().split('T')[0];
            
            const getFormattedPct = (value, total) => {
                if (total === 0) return "0";
                if (value === total) return "100";
                const raw = (value / total) * 100;
                return Math.min(raw, 99.9).toFixed(1);
            };
            
            const docsWithAnchorsPct = getFormattedPct(docsWithAnchors, allMdFiles.length);
            const linkedDocsPct = getFormattedPct(linkedNodes.length, enrichableNodes.length);
            const linkedCodePct = getFormattedPct(codeLinkedNodes.length, enrichableNodes.length);
            const godDocsPct = godNodes.length > 0 ? getFormattedPct(documentedGodNodesCount, godNodes.length) : "0";
            const godCodePct = godNodes.length > 0 ? getFormattedPct(codeLinkedGodNodesCount, godNodes.length) : "0";
            
            const getFormattedVal = (val) => {
                if (val === 100) return "100";
                return Math.min(val, 99.9).toFixed(1);
            };

            const newTraceabilityContent = `## Graph Traceability

> Auto-generated by \`/docs update --graph\` | Last scan: ${updatedDate}

| Metric | Value |
|:--|:--|
| Total docs | ${allMdFiles.length} |
| Docs with graph anchors | ${docsWithAnchors} (${docsWithAnchorsPct}%) |
| Graph nodes with docAnchors (CSA trên Docs) | ${linkedNodes.length}/${enrichableNodes.length} enrichable (${linkedDocsPct}%) |
| Graph nodes with para-doc (CSA trên Code) | ${codeLinkedNodes.length}/${enrichableNodes.length} enrichable (${linkedCodePct}%) |
| God Nodes covered (CSA trên Docs) | ${documentedGodNodesCount}/${godNodes.length} top-connected (${godDocsPct}%) |
| God Nodes covered (CSA trên Code) | ${codeLinkedGodNodesCount}/${godNodes.length} top-connected (${godCodePct}%) |
| Weighted Graph Coverage | ${getFormattedVal(weightedHealthScore)}% |
| Documentation Freshness/Sync Rate | ${getFormattedVal(serverHealthPct)}% |
| Overall Health Status Score | ${getFormattedVal(overallHealthScore)}/100 |
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
            console.warn('Warning: Failed to update Graph Traceability in README.md:', e.message);
        }
    }

    const searchIndex = [];
    for (const sourceFile of allMdFiles) {
        const relativeFromRoot = getVirtualRelativePath(sourceFile, srcDir);
        const targetFile = path.join(destDir, relativeFromRoot.replace(/\.md$/, '.html'));
        const fileAlignment = alignmentData[relativeFromRoot];
        const auditReports = fileAlignment ? fileAlignment.auditReports : [];
        const fileStats = fileAlignment ? fileAlignment.alignmentStats : null;
        renderSingleFile(sourceFile, targetFile, virtualRoot, srcDir, destDir, template, graphNodesMap, calculateBlastRadius, dashboardStats, auditReports, fileStats);
        
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
            
            const allMdFilesRelative = allMdFiles.map(filePath => getVirtualRelativePath(filePath, srcDir));
            
            console.log('DEBUG: alignmentData keys count:', Object.keys(alignmentData).length);
            console.log('DEBUG: first 3 keys of alignmentData:', Object.keys(alignmentData).slice(0, 3));
            
            dashboardHtml = dashboardHtml
                .replaceAll('/* WORKSPACE_LANG */', workspaceLang)
                .replaceAll('/* README_RELATIVE_URL */', relativeReadmeFromTarget)
                .replaceAll('/* SEARCH_INDEX_RELATIVE_URL */', relativeSearchIndexUrl)
                .replaceAll('/* RENDER_TIME */', renderTime)
                .replaceAll('/* KERNEL_VERSION */', kernelVersion)
                .replaceAll('<!-- DOCS_LIST_PLACEHOLDER -->', sidebarHtml)
                .replace(/const dashboardStats = [^;]+;/, 'window.PROJECT_CALIBRATION_CONFIG = ' + JSON.stringify(projectCalibration, null, 2) + ';\n                const dashboardStats = ' + JSON.stringify(dashboardStats, null, 2) + ';')
                .replace(/const graphNodesData = [^;]+;/, 'const graphNodesData = ' + JSON.stringify(processedNodesData, null, 2) + ';')
                .replace(/const existingSpecAnchorIdsData = [^;]+;/, 'const existingSpecAnchorIdsData = ' + JSON.stringify(Array.from(existingSpecAnchorIds)) + ';')
                .replace(/const allMarkdownFiles = [^;]+;/, 'const allMarkdownFiles = ' + JSON.stringify(allMdFilesRelative, null, 2) + ';')
                .replace(/const alignmentData = [^;]+;/, 'const alignmentData = ' + JSON.stringify(alignmentData, null, 2) + ';')
                .replace(/const definedAnchorsMapData = [^;]+;/, 'const definedAnchorsMapData = ' + JSON.stringify(definedAnchorsMap, null, 2) + ';');
                
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
                    const portalSidebarHtml = treeToHtml(virtualRoot, '', path.join(destDir, 'index.html'), virtualRoot.path, destDir, srcDir);
                    
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
                                renderSingleFile(srcPath, targetHtmlPath, virtualRoot, srcDir, destDir, template, graphNodesMap, calculateBlastRadius, dashboardStats, [], null);
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
    
    const projectDir = path.dirname(sourceDir);
    const sysdesignsDir = path.join(projectDir, 'artifacts', 'sysdesigns');
    const specsDir = path.join(projectDir, 'artifacts', 'specs');

    fs.watch(sourceDir, { recursive: true }, (eventType, filename) => {
        if (filename && filename.endsWith('.md')) {
            triggerRebuild();
        }
    });

    if (fs.existsSync(sysdesignsDir)) {
        fs.watch(sysdesignsDir, { recursive: true }, (eventType, filename) => {
            if (filename && filename.endsWith('.md')) {
                triggerRebuild();
            }
        });
    }

    if (fs.existsSync(specsDir)) {
        fs.watch(specsDir, { recursive: true }, (eventType, filename) => {
            if (filename && filename.endsWith('.md')) {
                triggerRebuild();
            }
        });
    }
}
