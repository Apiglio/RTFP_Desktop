function text_cleanup(node) {
	let raw = "";
	raw = node.textContent ?? "";
	return raw.replace(/&nbsp;/g, '').replace(/\s+/g, '').trim();
}

function sequence_to_object(list_of_dom) {
	//[a, b, c, d, ...] -> {a:b, c:d, ...}
	if(list_of_dom.length % 2 == 1) return;
	let obj = {};
	for(let i=0; i<list_of_dom.length/2; i++) {
		let key = text_cleanup(list_of_dom[2*i]).replace(/[:：]$/,'');
		let val = text_cleanup(list_of_dom[2*i+1]);
		obj[key] = val;
	}
	return obj;
}
function kvp_to_object(list_of_dom) {
	//["a:b", "c:d", ...] -> {a:b, c:d, ...}
	let obj = {};
	for(const dom of list_of_dom) {
		let kvp = text_cleanup(dom).replace("：",":");
		let [key, val] = kvp.split(":");
		obj[key] = val;
	}
	return obj;
}
function doms_to_paragraph(list_of_dom) {
	return [...list_of_dom].map(x=>x.textContent).join("\n");
}
function doms_to_links(list_of_dom) {
	let links = [...list_of_dom].map(x=>x.href);
	return [...new Set(links)];
}

const DEFAULT_EXTRACTORS = [
	{ mtd: "偶数列", field: null, filter: '.pchide.abstract.mxxgkabstract td', url:"www.gov.cn|." },
	{ mtd: "偶数列", field: null, filter: '.policyLibraryOverview_header td', url:"www.gov.cn|." },
	{ mtd: "段落", field: "原文", filter: '#UCAP-CONTENT p', url:"www.gov.cn|." },
	{ mtd: "偶数列", field: null, filter: '[role="viewlist"] .xl_con1 span, [role="viewlist"] .xl_con1 text', url:"fujian.gov.cn|." },
	{ mtd: "偶数列", field: null, filter: '.container div table tbody td', url:"fujian.gov.cn|." },
	{ mtd: "段落", field: "原文", filter: '#detailCont p, #detailCont text', url:"fujian.gov.cn|." },
	{ mtd: "键值对", field: null, filter: '[role="viewlist"] div.index_box li', url:"www.fuzhou.gov.cn|." },
	{ mtd: "段落", field: "原文", filter: '.word_con[avalonctrl="QzbView"] p', url:"www.fuzhou.gov.cn|." },
	{ mtd: "链接", field: "附件", filter: '[download]', url:"www.fuzhou.gov.cn|." }
];
const EXTRACTOR_MAP = {
	"偶数列":sequence_to_object,
	"键值对":kvp_to_object,
	"段落":doms_to_paragraph,
	"链接":doms_to_links
}

chrome.storage.local.get("extractors", (data) => {
	if (!data.extractors) {
		chrome.storage.local.set({ extractors: DEFAULT_EXTRACTORS });
	}
});