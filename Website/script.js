(function () {
  const year = document.querySelector("#year");
  if (year) {
    year.textContent = new Date().getFullYear();
  }

  document.querySelectorAll("[data-disabled-link]").forEach((link) => {
    link.addEventListener("click", (event) => event.preventDefault());
  });

  const form = document.querySelector("#feedbackForm");
  if (!form) {
    return;
  }

  const status = document.querySelector("#formStatus");
  const requiredFields = ["type", "email", "subject", "message", "privacy"];

  const messages = {
    type: "Bitte wähle aus, worum es geht.",
    email: "Bitte gib eine gültige E-Mail-Adresse ein.",
    subject: "Bitte gib einen Betreff ein.",
    message: "Bitte beschreibe dein Anliegen.",
    privacy: "Bitte stimme der Verarbeitung deiner Angaben zu."
  };

  function getField(name) {
    return form.elements[name];
  }

  function setError(name, message) {
    const field = getField(name);
    const error = document.querySelector(`#${name}-error`);
    if (error) {
      error.textContent = message || "";
    }
    if (field && field.type !== "checkbox") {
      field.setAttribute("aria-invalid", message ? "true" : "false");
      field.setAttribute("aria-describedby", message ? `${name}-error` : "");
    }
  }

  function validateField(name) {
    const field = getField(name);
    if (!field) {
      return true;
    }

    let isValid = true;
    if (field.type === "checkbox") {
      isValid = field.checked;
    } else if (name === "email") {
      isValid = field.value.trim() !== "" && field.validity.valid;
    } else {
      isValid = field.value.trim() !== "";
    }

    setError(name, isValid ? "" : messages[name]);
    return isValid;
  }

  requiredFields.forEach((name) => {
    const field = getField(name);
    if (!field) {
      return;
    }
    const eventName = field.type === "checkbox" || field.tagName === "SELECT" ? "change" : "input";
    field.addEventListener(eventName, () => validateField(name));
  });

  form.addEventListener("submit", (event) => {
    event.preventDefault();
    status.className = "form-status";
    status.textContent = "";

    const isValid = requiredFields.map(validateField).every(Boolean);
    if (!isValid) {
      status.classList.add("is-error");
      status.textContent = "Bitte prüfe die markierten Felder.";
      const firstInvalid = requiredFields.map(getField).find((field) => {
        return field && (field.getAttribute("aria-invalid") === "true" || (field.type === "checkbox" && !field.checked));
      });
      if (firstInvalid) {
        firstInvalid.focus();
      }
      return;
    }

    const payload = Object.fromEntries(new FormData(form).entries());
    payload.privacy = getField("privacy").checked;

    // TODO: Hier später fetch("/api/contact", { method: "POST", body: JSON.stringify(payload) }) ergänzen.
    console.info("MeterMind feedback payload prepared", payload);

    status.classList.add("is-success");
    status.textContent = "Danke, deine Nachricht wurde vorbereitet.";
    form.reset();
    requiredFields.forEach((name) => setError(name, ""));
  });
})();
