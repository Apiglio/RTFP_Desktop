chrome.commands.onCommand.addListener((command) => {
  if (command === "extract-policy-popup") {
    chrome.tabs.query({ active: true, currentWindow: true }, (tabs) => {
      if (tabs[0]?.id) {
        chrome.tabs.sendMessage(tabs[0].id, { action: "showPolicyPopup" });
      }
    });
  }
});