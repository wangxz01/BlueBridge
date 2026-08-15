"use client";

import { useEffect, useMemo, useState } from "react";

type Lang = "zh" | "en";
type View = "home" | "devices" | "presets" | "settings";

const copy = {
  zh: {
    hello: "下午好，Adam",
    subtitle: "你的声音，已经连接好了。",
    workspace: "控制中心",
    home: "总览",
    devices: "设备",
    presets: "场景",
    settings: "设置",
    localOnly: "本地优先",
    privacy: "音频仅在你的设备间加密传输，不上传云端。",
    online: "3 台设备在线",
    currentRoute: "正在运行",
    activeTitle: "Gaming + Study",
    stop: "停止",
    stopped: "已暂停",
    resume: "恢复",
    phone: "Pixel 9",
    phoneAudio: "手机音频",
    computer: "This Windows PC",
    mixer: "混音中心",
    headset: "Nova Pro Wireless",
    output: "2.4G 输出",
    lan: "局域网 + 标准蓝牙",
    excellent: "连接优秀",
    quick: "创建新路由",
    quickHint: "选择来源、目标和输出，然后启动。",
    source: "音频来源",
    target: "目标设备",
    outputDevice: "输出设备",
    start: "启动路由",
    mixerTitle: "实时混音",
    mixerHint: "每一路声音都可以独立调节。",
    localGame: "本机 · Game",
    mobileAudio: "Pixel 9 · Media",
    discord: "Discord · Voice",
    local: "本机",
    bluetooth: "标准蓝牙",
    app: "应用",
    nearby: "附近设备",
    nearbyHint: "已通过可信配对验证，可自动重连。",
    manage: "管理全部",
    winDesc: "当前混音输出端",
    macDesc: "Wi-Fi · 可作为来源",
    androidDesc: "标准蓝牙 + BlueBridge",
    scenes: "快捷场景",
    scenesHint: "一键恢复常用路由、音量和连接策略。",
    gamingDesc: "手机音频与本机游戏同时输出到一副耳机。",
    library: "Library",
    libraryDesc: "Mac 通过热点发送到 Android，再输出到蓝牙耳机。",
    run: "运行",
    routeStarted: "路由已启动，正在自动选择最佳本地链路。",
    routeStopped: "音频路由已暂停，场景配置已保留。",
    volumeUpdated: "音量设置已更新。",
    presetStarted: "场景已恢复，所有设备正在自动重连。",
    settingsTitle: "偏好设置",
    settingsHint: "这些选项只保存在当前设备。",
    autoReconnect: "自动重连",
    autoReconnectHint: "可信设备恢复在线后继续上次场景",
    bestLink: "自动选择最佳链路",
    bestLinkHint: "优先局域网，不可用时回退到 BlueBridge Bluetooth",
    loopGuard: "音频回环保护",
    loopGuardHint: "防止 BlueBridge 输出被重新捕获",
    deviceTitle: "所有可信设备",
    deviceHint: "首次连接必须在两台设备上确认。",
    pair: "配对新设备",
    demoNote: "交互原型",
    demoCopy: "当前为控制层演示；系统级音频驱动与蓝牙接收器需在原生客户端中实现。",
  },
  en: {
    hello: "Good afternoon, Adam",
    subtitle: "Your audio is connected and ready.",
    workspace: "Control center",
    home: "Overview",
    devices: "Devices",
    presets: "Presets",
    settings: "Settings",
    localOnly: "Local first",
    privacy: "Audio is encrypted between your devices and never uploaded.",
    online: "3 devices online",
    currentRoute: "Live route",
    activeTitle: "Gaming + Study",
    stop: "Stop",
    stopped: "Paused",
    resume: "Resume",
    phone: "Pixel 9",
    phoneAudio: "Phone audio",
    computer: "This Windows PC",
    mixer: "Mix hub",
    headset: "Nova Pro Wireless",
    output: "2.4G output",
    lan: "LAN + standard Bluetooth",
    excellent: "Excellent link",
    quick: "Create a new route",
    quickHint: "Choose a source, target and output, then start.",
    source: "Audio source",
    target: "Target device",
    outputDevice: "Output device",
    start: "Start route",
    mixerTitle: "Live mixer",
    mixerHint: "Tune each source independently.",
    localGame: "Local · Game",
    mobileAudio: "Pixel 9 · Media",
    discord: "Discord · Voice",
    local: "Local",
    bluetooth: "Standard BT",
    app: "App",
    nearby: "Nearby devices",
    nearbyHint: "Trusted, verified and ready to reconnect.",
    manage: "Manage all",
    winDesc: "Current mix output",
    macDesc: "Wi-Fi · Available source",
    androidDesc: "Standard BT + BlueBridge",
    scenes: "Quick presets",
    scenesHint: "Restore routes, volume and connection policy in one click.",
    gamingDesc: "Mix phone audio with local game sound in one headset.",
    library: "Library",
    libraryDesc: "Send Mac audio over hotspot to Android and Bluetooth headphones.",
    run: "Run",
    routeStarted: "Route started. Choosing the best local link automatically.",
    routeStopped: "Audio route paused. Your preset is preserved.",
    volumeUpdated: "Volume setting updated.",
    presetStarted: "Preset restored. Devices are reconnecting automatically.",
    settingsTitle: "Preferences",
    settingsHint: "These options are stored on this device only.",
    autoReconnect: "Auto reconnect",
    autoReconnectHint: "Resume the last preset when trusted devices return",
    bestLink: "Choose the best link",
    bestLinkHint: "Prefer LAN, then fall back to BlueBridge Bluetooth",
    loopGuard: "Audio loop protection",
    loopGuardHint: "Prevent BlueBridge output from being captured again",
    deviceTitle: "All trusted devices",
    deviceHint: "First-time connections must be confirmed on both devices.",
    pair: "Pair a new device",
    demoNote: "Interactive prototype",
    demoCopy: "This is the control-layer demo; native clients provide system audio drivers and Bluetooth receiving.",
  },
} as const;

const navItems: { id: View; icon: string }[] = [
  { id: "home", icon: "◫" },
  { id: "devices", icon: "◇" },
  { id: "presets", icon: "✦" },
  { id: "settings", icon: "⚙" },
];

export function BlueBridgeApp() {
  const [lang, setLang] = useState<Lang>("zh");
  const [view, setView] = useState<View>("home");
  const [running, setRunning] = useState(true);
  const [toast, setToast] = useState("");
  const [source, setSource] = useState("Pixel 9 · Media");
  const [target, setTarget] = useState("This Windows PC");
  const [output, setOutput] = useState("Nova Pro Wireless");
  const [settings, setSettings] = useState([true, true, true]);
  const t = copy[lang];

  useEffect(() => {
    try {
      const saved = window.localStorage.getItem("bluebridge-language");
      if (saved === "zh" || saved === "en") setLang(saved);
    } catch {
      // Device-local preferences are optional in private browsing contexts.
    }
  }, []);

  useEffect(() => {
    if (!toast) return;
    const timer = window.setTimeout(() => setToast(""), 2600);
    return () => window.clearTimeout(timer);
  }, [toast]);

  function switchLanguage() {
    const next = lang === "zh" ? "en" : "zh";
    setLang(next);
    try {
      window.localStorage.setItem("bluebridge-language", next);
    } catch {
      // The interface still switches when local storage is unavailable.
    }
  }

  function startRoute(message = t.routeStarted) {
    setRunning(true);
    setToast(message);
    setView("home");
  }

  const navLabel = useMemo(
    () => ({ home: t.home, devices: t.devices, presets: t.presets, settings: t.settings }),
    [t],
  );

  return (
    <div className="app-shell">
      <aside className="sidebar" aria-label={t.workspace}>
        <div className="brand">
          <span className="brand-mark" aria-hidden="true" />
          BlueBridge
        </div>
        <div className="nav-label">{t.workspace}</div>
        <nav className="nav-list">
          {navItems.map((item) => (
            <button
              className={`nav-item ${view === item.id ? "active" : ""}`}
              key={item.id}
              onClick={() => setView(item.id)}
              type="button"
            >
              <span className="nav-icon" aria-hidden="true">{item.icon}</span>
              {navLabel[item.id]}
            </button>
          ))}
        </nav>
        <div className="sidebar-spacer" />
        <div className="privacy-card">
          <div className="privacy-title"><span aria-hidden="true">⌾</span>{t.localOnly}</div>
          {t.privacy}
        </div>
      </aside>

      <main className="main">
        <header className="topbar">
          <div>
            <p className="eyebrow">BlueBridge · {t.workspace}</p>
            <h1>{view === "home" ? t.hello : navLabel[view]}</h1>
            {view === "home" && <p className="section-subtitle" style={{ margin: "7px 0 0" }}>{t.subtitle}</p>}
          </div>
          <div className="top-actions">
            <div className="connection-pill"><span className="live-dot" />{t.online}</div>
            <button className="language-toggle" onClick={switchLanguage} type="button" aria-label="Switch language">
              {lang === "zh" ? "EN" : "中文"}
            </button>
            <button className="icon-button" type="button" aria-label="Notifications">◌</button>
          </div>
        </header>

        {view === "home" && (
          <div className="view">
            <section className="dashboard-grid" aria-label={t.home}>
              <ActiveRoute t={t} running={running} onToggle={() => {
                setRunning((value) => !value);
                setToast(running ? t.routeStopped : t.routeStarted);
              }} />
              <QuickStart
                t={t}
                source={source}
                setSource={setSource}
                target={target}
                setTarget={setTarget}
                output={output}
                setOutput={setOutput}
                onStart={() => startRoute()}
              />
            </section>

            <section className="wide-section">
              <div className="section-title">
                <div><h2>{t.mixerTitle}</h2><p>{t.mixerHint}</p></div>
              </div>
              <Mixer t={t} onChange={() => setToast(t.volumeUpdated)} />
            </section>

            <section className="wide-section">
              <div className="section-title">
                <div><h2>{t.nearby}</h2><p>{t.nearbyHint}</p></div>
                <button className="text-button" onClick={() => setView("devices")} type="button">{t.manage} →</button>
              </div>
              <Devices t={t} />
            </section>

            <section className="wide-section">
              <div className="section-title">
                <div><h2>{t.scenes}</h2><p>{t.scenesHint}</p></div>
              </div>
              <Presets t={t} onRun={() => startRoute(t.presetStarted)} />
            </section>
          </div>
        )}

        {view === "devices" && (
          <div className="view">
            <section className="section-title">
              <div><h2>{t.deviceTitle}</h2><p>{t.deviceHint}</p></div>
              <button className="primary-button" style={{ minHeight: 39, padding: "0 15px", margin: 0 }} onClick={() => setToast(lang === "zh" ? "正在扫描附近的 BlueBridge 设备…" : "Scanning for nearby BlueBridge devices…")} type="button">＋ {t.pair}</button>
            </section>
            <Devices t={t} />
            <section className="panel empty-view" style={{ marginTop: 18, minHeight: 250 }}>
              <div>
                <div className="empty-visual">⌁</div>
                <h2>{t.demoNote}</h2>
                <p>{t.demoCopy}</p>
              </div>
            </section>
          </div>
        )}

        {view === "presets" && (
          <div className="view">
            <div className="section-title"><div><h2>{t.scenes}</h2><p>{t.scenesHint}</p></div></div>
            <Presets t={t} onRun={() => startRoute(t.presetStarted)} />
          </div>
        )}

        {view === "settings" && (
          <section className="panel empty-view view">
            <div>
              <div className="empty-visual">⚙</div>
              <h2>{t.settingsTitle}</h2>
              <p>{t.settingsHint}</p>
              <div className="settings-list">
                {[
                  [t.autoReconnect, t.autoReconnectHint],
                  [t.bestLink, t.bestLinkHint],
                  [t.loopGuard, t.loopGuardHint],
                ].map(([title, hint], index) => (
                  <div className="setting-row" key={title}>
                    <div><strong>{title}</strong><small>{hint}</small></div>
                    <button
                      className={`switch ${settings[index] ? "on" : ""}`}
                      onClick={() => setSettings((current) => current.map((value, i) => i === index ? !value : value))}
                      aria-pressed={settings[index]}
                      aria-label={title}
                      type="button"
                    />
                  </div>
                ))}
              </div>
            </div>
          </section>
        )}
      </main>

      <nav className="mobile-nav" aria-label={t.workspace}>
        {navItems.map((item) => (
          <button className={view === item.id ? "active" : ""} key={item.id} onClick={() => setView(item.id)} type="button">
            <span aria-hidden="true">{item.icon}</span>{navLabel[item.id]}
          </button>
        ))}
      </nav>

      {toast && <div className="toast" role="status">{toast}</div>}
    </div>
  );
}

function ActiveRoute({ t, running, onToggle }: { t: typeof copy.zh | typeof copy.en; running: boolean; onToggle: () => void }) {
  return (
    <article className="panel active-route">
      <div className="panel-head">
        <div>
          <div className="panel-kicker"><span className="route-pulse" />{running ? t.currentRoute : t.stopped}</div>
          <h2>{t.activeTitle}</h2>
        </div>
        <button className="stop-button" onClick={onToggle} type="button">{running ? "Ⅱ  " + t.stop : "▶  " + t.resume}</button>
      </div>
      <div className="route-flow" style={{ opacity: running ? 1 : .56 }}>
        <div className="flow-node">
          <div className="device-orb">▯</div>
          <strong>{t.phone}</strong><small>{t.phoneAudio}</small>
        </div>
        <div className="flow-line" />
        <div className="flow-node">
          <div className="device-orb hub">▰</div>
          <strong>{t.computer}</strong><small>{t.mixer}</small>
        </div>
        <div className="flow-line" />
        <div className="flow-node">
          <div className="device-orb">⌾</div>
          <strong>{t.headset}</strong><small>{t.output}</small>
        </div>
      </div>
      <div className="route-stats">
        <span className="stat-chip">↯ 18 ms</span>
        <span className="stat-chip">◎ {t.lan}</span>
        <span className="stat-chip">48 kHz · 24 bit</span>
        <span className="stat-chip">▥ {t.excellent}</span>
      </div>
    </article>
  );
}

function QuickStart({ t, source, setSource, target, setTarget, output, setOutput, onStart }: {
  t: typeof copy.zh | typeof copy.en;
  source: string; setSource: (value: string) => void;
  target: string; setTarget: (value: string) => void;
  output: string; setOutput: (value: string) => void;
  onStart: () => void;
}) {
  const fields = [
    { label: t.source, value: source, set: setSource, options: ["Pixel 9 · Media", "This Windows PC · Game", "MacBook Air · System"] },
    { label: t.target, value: target, set: setTarget, options: ["This Windows PC", "Pixel 9", "MacBook Air"] },
    { label: t.outputDevice, value: output, set: setOutput, options: ["Nova Pro Wireless", "Pixel Buds Pro", "MacBook Speakers"] },
  ];
  return (
    <article className="panel quick-start">
      <h2>{t.quick}</h2><p className="section-subtitle">{t.quickHint}</p>
      <div className="route-form">
        {fields.map((field, index) => (
          <div className="form-step" key={field.label}>
            <span className="step-number">0{index + 1}</span>
            <div>
              <label htmlFor={`route-field-${index}`}>{field.label}</label>
              <div className="select-wrap">
                <select id={`route-field-${index}`} value={field.value} onChange={(event) => field.set(event.target.value)}>
                  {field.options.map((option) => <option key={option}>{option}</option>)}
                </select>
              </div>
            </div>
          </div>
        ))}
        <button className="primary-button" onClick={onStart} type="button">▶&nbsp;&nbsp;{t.start}</button>
      </div>
    </article>
  );
}

function Mixer({ t, onChange }: { t: typeof copy.zh | typeof copy.en; onChange: () => void }) {
  const [channels, setChannels] = useState([
    { name: t.localGame, tag: t.local, icon: "▰", style: "local", volume: 82, muted: false },
    { name: t.mobileAudio, tag: t.bluetooth, icon: "▯", style: "bt", volume: 64, muted: false },
    { name: t.discord, tag: t.app, icon: "◉", style: "", volume: 72, muted: false },
  ]);

  useEffect(() => {
    setChannels((current) => current.map((channel, index) => ({
      ...channel,
      name: [t.localGame, t.mobileAudio, t.discord][index],
      tag: [t.local, t.bluetooth, t.app][index],
    })));
  }, [t]);

  return (
    <div className="mixer-grid">
      {channels.map((channel, index) => (
        <div className="mixer-card" key={channel.name}>
          <div className={`source-icon ${channel.style}`}>{channel.icon}</div>
          <div className="mixer-copy">
            <div className="mixer-name">{channel.name}<span className="source-tag">{channel.tag}</span></div>
            <div className="volume-row">
              <input
                aria-label={`${channel.name} volume`}
                type="range" min="0" max="100" value={channel.volume}
                onChange={(event) => setChannels((current) => current.map((item, i) => i === index ? { ...item, volume: Number(event.target.value) } : item))}
                onPointerUp={onChange}
              />
              <output>{channel.volume}%</output>
            </div>
          </div>
          <button
            className={`mute-button ${channel.muted ? "muted" : ""}`}
            onClick={() => setChannels((current) => current.map((item, i) => i === index ? { ...item, muted: !item.muted } : item))}
            aria-label={`Mute ${channel.name}`}
            aria-pressed={channel.muted}
            type="button"
          >{channel.muted ? "×" : "◖"}</button>
        </div>
      ))}
    </div>
  );
}

function Devices({ t }: { t: typeof copy.zh | typeof copy.en }) {
  const devices = [
    { glyph: "▰", name: "This Windows PC", description: t.winDesc, meta: ["Windows 11", "18 ms"] },
    { glyph: "▱", name: "MacBook Air", description: t.macDesc, meta: ["macOS", "24 ms"] },
    { glyph: "▯", name: "Pixel 9", description: t.androidDesc, meta: ["Android", "12 ms"] },
  ];
  return (
    <div className="device-grid">
      {devices.map((device) => (
        <article className="device-card" key={device.name}>
          <div className="device-top"><span className="device-glyph">{device.glyph}</span><span className="device-status">Online</span></div>
          <h3>{device.name}</h3><p>{device.description}</p>
          <div className="device-meta">{device.meta.map((item) => <span className="mini-chip" key={item}>{item}</span>)}</div>
        </article>
      ))}
    </div>
  );
}

function Presets({ t, onRun }: { t: typeof copy.zh | typeof copy.en; onRun: () => void }) {
  return (
    <div className="preset-grid">
      <article className="preset-card featured">
        <div className="preset-top"><span className="preset-badge">Recommended</span><button className="preset-run" onClick={onRun} aria-label={`${t.run} Gaming + Study`} type="button">▶</button></div>
        <h3>Gaming + Study</h3><p>{t.gamingDesc}</p>
        <div className="preset-route"><span className="mini-chip">Pixel 9</span><span className="mini-chip">→</span><span className="mini-chip">Windows</span><span className="mini-chip">→</span><span className="mini-chip">2.4G</span></div>
      </article>
      <article className="preset-card">
        <div className="preset-top"><span className="device-glyph">⌂</span><button className="preset-run" onClick={onRun} aria-label={`${t.run} Library`} type="button">▶</button></div>
        <h3>{t.library}</h3><p>{t.libraryDesc}</p>
        <div className="preset-route"><span className="mini-chip">Mac</span><span className="mini-chip">→</span><span className="mini-chip">Android</span><span className="mini-chip">→</span><span className="mini-chip">Bluetooth</span></div>
      </article>
    </div>
  );
}
