const container = document.querySelector("div#extractors");
container.addEventListener("click", (e) => {
	if (e.target.className == "delete") {
		if(e.target.closest(".settings").children.length>2) {
			e.target.closest(".setting").remove();
		}
	}
	else if (e.target.className == "append") {
		const tpl = container.querySelector(".setting");
		const item = tpl.cloneNode(true);
		item.querySelector("textarea#rule").value = "";
		item.querySelector("textarea#url").value = "";
		container.insertBefore(item, container.lastElementChild);
	}
});

function render_extractors(extractors) {
	const container = document.querySelector("div#extractors");
	while (container.children.length<=extractors.length) {
		const tpl = container.querySelector(".setting");
		const item = tpl.cloneNode(true);
		container.insertBefore(item, container.lastElementChild);
	}
	while (container.children.length>extractors.length+1) {
		container.removeChild(container.children[0])
	}
	for (let idx in extractors) {
		let item = container.children[idx];
		item.querySelector("textarea#rule").value = extractors[idx]["filter"];
		item.querySelector("textarea#url").value = extractors[idx]["url"];
		item.querySelector("select#mtd").value = extractors[idx]["mtd"];
		if (extractors[idx]["field"]) {
			item.querySelector("select#field").value = extractors[idx]["field"];
		} else {
			item.querySelector("select#field").value="";
		}
	}
}

function get_extractors() {
	let result=[];
	const container = document.querySelector("div#extractors");
	for (let item of extractors.children) {
		let extr = {};
		if (!item?.querySelector("textarea#rule")) continue;
		extr["filter"] = item.querySelector("textarea#rule").value;
		extr["url"] = item.querySelector("textarea#url").value;
		extr["mtd"] = item.querySelector("select#mtd").value;
		extr["field"] = item.querySelector("select#field").value;
		if (extr["field"] == "") extr["field"]=null;
		result.push(extr);
	}
	return(result);
}

const button_discard = document.querySelector("button#btn-discard");
button_discard.addEventListener("click", (e) => {
	chrome.storage.local.get("extractors", (data) => {
		let extractors = data.extractors;
		render_extractors(extractors);
	});
});

const button_restore = document.querySelector("button#btn-restore");
button_restore.addEventListener("click", (e) => {
	if (!confirm("还原为初始设置？")) return;
	chrome.storage.local.get("extractors", (data) => {
		render_extractors(DEFAULT_EXTRACTORS);
		chrome.storage.local.set({ extractors: DEFAULT_EXTRACTORS });
	});
});

const button_save = document.querySelector("button#btn-save");
button_save.addEventListener("click", (e) => {
	chrome.storage.local.set({ extractors: get_extractors() });
});

document.addEventListener("DOMContentLoaded", () => {
	chrome.storage.local.get("extractors", (data) => {
		let extractors = data.extractors;
		render_extractors(extractors);
	});
});

const button_export = document.querySelector("button#btn-export");
button_export.addEventListener("click", (e) => {
	chrome.storage.local.get("extractors", (data) => {
		const rules = data.extractors || DEFAULT_EXTRACTORS;
		const jsonText = JSON.stringify(rules, null, 2);
		const blob = new Blob([jsonText], { type: "application/json" });
		const url = URL.createObjectURL(blob);
		const a = document.createElement("a");
		a.href = url;
		a.download = "rtfp_extractors.json";
		a.click();
		URL.revokeObjectURL(url);
	});
});

const button_import = document.querySelector("button#btn-import");
button_import.addEventListener("click", (e) => {
	document.querySelector("#file-import").click();
});

document.querySelector("#file-import").addEventListener("change", (e) => {
	const file = e.target.files[0];
	if (!file) return;
	const reader = new FileReader();
	reader.onload = (event) => {
		try {
			const importedRules = JSON.parse(event.target.result);
			if (!Array.isArray(importedRules)) {
				throw new Error("JSON 格式不正确，应该是一个数组");
			}
			chrome.storage.local.set({ customRules: importedRules }, () => {
				render_extractors(importedRules);
				alert("导入成功！");
			});
		} catch (err) {
			alert("导入失败：" + err.message);
		}
		e.target.value = "";
	};
	reader.readAsText(file);
});