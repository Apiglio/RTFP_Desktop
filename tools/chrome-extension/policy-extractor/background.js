function triggerPolicyExtraction() {
	chrome.tabs.query({ active: true, currentWindow: true }, (tabs) => {
		const tab = tabs[0];
		if(!tab?.id) return;
		chrome.tabs.sendMessage(tab.id, { action: "showPolicyPopup" }, () => {
			if (chrome.runtime.lastError) {
				console.warn("sendMessage failed:", chrome.runtime.lastError.message);
			}
		});
	});
}

chrome.commands.onCommand.addListener((command) => {
	if(command === "extract-policy-popup") {
		triggerPolicyExtraction();
	}
});

chrome.runtime.onMessage.addListener((message, sender, sendResponse) => {
	if (message.action === "triggerExtractPolicy") {
		triggerPolicyExtraction();
		sendResponse({ ok: true });
	}
});