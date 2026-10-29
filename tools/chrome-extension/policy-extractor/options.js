const container = document.querySelector("div.settings");
container.addEventListener("click", (e) => {
	if (e.target.className == "delete") {
		e.target.closest(".setting").remove();
	}
	else if (e.target.className == "append") {
		const tpl = container.querySelector(".setting");
		const item = tpl.cloneNode(true);
		item.querySelector("textarea").value = "";
		container.insertBefore(item, container.lastElementChild);
	}
});