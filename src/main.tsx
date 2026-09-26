import React from "react";
import { createRoot } from "react-dom/client";
import "./styles.css";
import App from "./App";
import { initVConsole } from "./lib/vconsole";

initVConsole();

createRoot(document.getElementById("root")!).render(
  <React.StrictMode>
    <App />
  </React.StrictMode>,
);
