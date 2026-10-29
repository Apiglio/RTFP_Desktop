const DEFAULT_EXTRACTORS = [
	//www.gov.cn
	{ mtd: "偶数列", field: null, filter: '.pchide.abstract.mxxgkabstract td' },
	{ mtd: "偶数列", field: null, filter: '.policyLibraryOverview_header td' },
	{ mtd: "段落", field: "原文", filter: '#UCAP-CONTENT p' },
	//fujian.gov.cn
	{ mtd: "偶数列", field: null, filter: '[role="viewlist"] .xl_con1 span, [role="viewlist"] .xl_con1 text' },
	{ mtd: "偶数列", field: null, filter: '.container div table tbody td' },
	{ mtd: "段落", field: "原文", filter: '#detailCont p, #detailCont text' },
	//www.fuzhou.gov.cn
	{ mtd: "键值对", field: null, filter: '[role="viewlist"] div.index_box li' },
	{ mtd: "段落", field: "原文", filter: '.word_con[avalonctrl="QzbView"] p' },
	{ mtd: "链接", field: "附件", filter: '[download]' },
	{}
];
const EXTRACTOR_MAP = {
	"偶数列":sequence_to_object,
	"键值对":kvp_to_object,
	"段落":doms_to_paragraph,
	"链接":doms_to_links
}

chrome.storage.local.get("customRules", (data) => {
	if (!data.customRules) {
		chrome.storage.local.set({ customRules: DEFAULT_EXTRACTORS });
	}
});

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

chrome.runtime.onMessage.addListener((message, sender, sendResponse) => {
	if (message.action === "showPolicyPopup") {
		chrome.storage.local.get("customRules", (data) => {
			try {
				let policy_info = {};			
				let extractors = data.customRules || DEFAULT_EXTRACTORS;
				
				for(exr of extractors) {
					let func;
					if (exr["mtd"]) {
						func = EXTRACTOR_MAP[exr["mtd"]];
					} else {
						continue;
					}
					let items = document.querySelectorAll(exr["filter"]);
					if (items.length==0) continue;
					if (exr["field"]) {
						policy_info[exr["field"]] = func(items);
					} else {
						policy_info = {...policy_info, ...func(items)};
					}
				}
				
				showPolicyPopup(JSON.stringify(policy_info, null, 2));
			} catch (e) {
				showPolicyPopup("提取出错: " + e.message, true);
			}
		});
	}
});

function showPolicyPopup(content, isError = false) {
	const old = document.getElementById("__rtfp_policy_extractor_popup__");
	if (old) old.remove();
	
	const overlay = document.createElement("div");
	overlay.id = "__rtfp_policy_extractor_popup__";
	const box = document.createElement("div");
	box.className = "pe-box";
	const closeBtn = document.createElement("button");
	closeBtn.textContent = "✕";
	closeBtn.className = "pe-close";
	closeBtn.onclick = () => overlay.remove();
	const ta = document.createElement("textarea");
	ta.value = content;
	ta.readOnly = true;
	ta.spellcheck = false;
	ta.className = "pe-textarea" + (isError ? " pe-error" : "");
	setTimeout(() => { ta.focus(); ta.select(); }, 0);
	
	const btnRow = document.createElement("div");
	btnRow.className = "pe-btn-row";
	const copyBtn = document.createElement("button");
	copyBtn.textContent = "全选并复制";
	copyBtn.className = "pe-copy-btn";
	copyBtn.onclick = async () => {
		ta.focus();
		ta.select();
		try {
			await navigator.clipboard.writeText(ta.value);
			copyBtn.textContent = "已复制 ✓";
		} catch {
			document.execCommand("copy");
			copyBtn.textContent = "已复制 ✓";
		}
		setTimeout(() => { copyBtn.textContent = "全选并复制"; }, 1500);
	};
	
	const rtfpBtn = document.createElement("button");
	rtfpBtn.textContent = "复制为RTFP节点";
	rtfpBtn.className = "pe-rtfp-btn";
	rtfpBtn.onclick = async () => {
		let raw;
		try {
			raw = JSON.parse(ta.value);
		} catch {
			rtfpBtn.textContent = "解析失败";
			setTimeout(() => { rtfpBtn.textContent = "复制为RTFP节点"; }, 1500);
			return;
		}
		const url = location.href;
		const rtfp = {
			"paper.buf": {
				"是否备份": false,
				"目录": "weblnk",
				"文件名": url,
				"文件大小": 0,
				"文件哈希": ""
			},
			"文献基础信息": {
				"类型": "",
				"标题": raw["标题"] ?? raw["名称"] ?? "",
				"作者": raw["发文机关"] ?? raw["发布机构"] ?? "",
				"ISBN": raw["发文字号"] ?? raw["文号"] ?? "",
				"链接": url
			},
			"政策": {
				"原文": raw["原文"] ?? "",
				"文号": raw["发文字号"] ?? raw["文号"] ?? "",
				"附件": raw["附件"]?.join("\n") ?? ""
			}
		};
		const text = JSON.stringify(rtfp, null, 2);
		try {
			await navigator.clipboard.writeText(text);
			rtfpBtn.textContent = "已复制 ✓";
		} catch {
			document.execCommand("copy");
			rtfpBtn.textContent = "已复制 ✓";
		}
		setTimeout(() => { rtfpBtn.textContent = "复制为RTFP节点"; }, 1500);
	};
	btnRow.appendChild(copyBtn);
	btnRow.appendChild(rtfpBtn);
	box.appendChild(closeBtn);
	box.appendChild(ta);
	box.appendChild(btnRow);
	overlay.appendChild(box);
	document.body.appendChild(overlay);
	overlay.addEventListener("click", (e) => {
		if (e.target === overlay) overlay.remove();
	});
}