document.getElementById("extract").addEventListener("click", () => {
	chrome.runtime.sendMessage({ action: "triggerExtractPolicy" }, () => {
		window.close();
	});
});

document.getElementById("settings").addEventListener("click", () => {
	chrome.runtime.openOptionsPage();
	window.close();
});