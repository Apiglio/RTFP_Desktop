const container = document.querySelector("div#extractors");
container.addEventListener("click", (e) => {
	if (e.target.className == "delete") {
		let c = e.target.closest(".setting");
		if(c.children.length>2) {
			e.target.closest(".setting").remove();
		}
	}
	else if (e.target.className == "append") {
		const tpl = container.querySelector(".setting");
		const item = tpl.cloneNode(true);
		item.querySelector("textarea").value = "";
		container.insertBefore(item, container.lastElementChild);
	}
});

const button_discard = document.querySelector("button#btn-discard");
button_discard.addEventListener("click", (e) => {
	chrome.storage.local.get("customRules", (data) => {
		let extractors = data.customRules;
		while (container.children.length<=extractors.length) {
			const tpl = container.querySelector(".setting");
			const item = tpl.cloneNode(true);
			container.insertBefore(item, container.lastElementChild);
		}
		for (let idx in extractors) {
			let item = container.children[idx];
			item.querySelector("textarea").value = extractors[idx]["filter"];
			item.querySelector("select#mtd").value = extractors[idx]["mtd"];
			item.querySelector("select#field").value = extractors[idx]["field"];
		}
	});
});
