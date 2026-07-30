/**
 * DOM Viewport & Mobile Overflow Inspector for Chrome DevTools MCP
 * Pass this function body to evaluate_script to perform automated DOM inspection.
 */
(() => {
  const documentWidth = document.documentElement.clientWidth;
  const scrollWidth = document.documentElement.scrollWidth;
  const hasHorizontalOverflow = scrollWidth > documentWidth;

  const overflowingElements = [];
  const smallTouchTargets = [];

  // 1. Scan for elements spilling out of the horizontal viewport
  const allElements = document.querySelectorAll('*');
  allElements.forEach(el => {
    const rect = el.getBoundingClientRect();
    if (rect.right > documentWidth + 1 && rect.width > 0 && rect.height > 0) {
      const id = el.id ? `#${el.id}` : '';
      const className = el.className && typeof el.className === 'string' ? `.${el.className.split(' ').join('.')}` : '';
      overflowingElements.push({
        tag: el.tagName.toLowerCase(),
        selector: `${el.tagName.toLowerCase()}${id}${className}`,
        right: Math.round(rect.right),
        width: Math.round(rect.width),
        overflowByPx: Math.round(rect.right - documentWidth)
      });
    }
  });

  // 2. Scan for interactive touch targets smaller than 44x44px
  const interactiveElements = document.querySelectorAll('button, a, input, select, textarea');
  interactiveElements.forEach(el => {
    const rect = el.getBoundingClientRect();
    if ((rect.width > 0 && rect.height > 0) && (rect.width < 44 || rect.height < 44)) {
      const id = el.id ? `#${el.id}` : '';
      const text = (el.innerText || el.value || '').trim().substring(0, 20);
      smallTouchTargets.push({
        selector: `${el.tagName.toLowerCase()}${id}`,
        text: text,
        width: Math.round(rect.width),
        height: Math.round(rect.height)
      });
    }
  });

  // 3. Scan for media elements without max-width constraint (R4)
  const unconstrainedMedia = [];
  const mediaElements = document.querySelectorAll('img, video, iframe, svg, canvas');
  mediaElements.forEach(el => {
    const computed = window.getComputedStyle(el);
    const maxWidth = computed.getPropertyValue('max-width');
    if (maxWidth === 'none' || maxWidth === '') {
      const rect = el.getBoundingClientRect();
      if (rect.width > 0 && rect.height > 0) {
        const id = el.id ? `#${el.id}` : '';
        const src = el.src ? el.src.split('/').pop().substring(0, 30) : '';
        unconstrainedMedia.push({
          tag: el.tagName.toLowerCase(),
          selector: `${el.tagName.toLowerCase()}${id}`,
          src: src,
          width: Math.round(rect.width),
          computedMaxWidth: maxWidth
        });
      }
    }
  });

  return {
    viewportWidth: documentWidth,
    scrollWidth: scrollWidth,
    hasHorizontalOverflow: hasHorizontalOverflow,
    overflowAmountPx: scrollWidth - documentWidth,
    overflowingElementsCount: overflowingElements.length,
    overflowingElements: overflowingElements.slice(0, 10), // Limit top 10
    smallTouchTargetsCount: smallTouchTargets.length,
    smallTouchTargets: smallTouchTargets.slice(0, 10),
    unconstrainedMediaCount: unconstrainedMedia.length,
    unconstrainedMedia: unconstrainedMedia.slice(0, 10),
    verdict: (!hasHorizontalOverflow && smallTouchTargets.length === 0 && unconstrainedMedia.length === 0) ? 'PASS' : 'FAIL'
  };
})();
