"use client";

import { useEffect, useState } from "react";

type View = "route" | "devices" | "presets" | "settings";

const nav: { id: View; label: string; number: string }[] = [
  { id: "route", label: "音频路由", number: "01" },
  { id: "devices", label: "设备", number: "02" },
  { id: "presets", label: "场景", number: "03" },
  { id: "settings", label: "设置", number: "04" },
];

const devices = [
  { name: "本机 Windows", platform: "Windows 11", detail: "混音输出 · 18 ms" },
  { name: "Pixel 9", platform: "Android", detail: "标准蓝牙" },
  { name: "MacBook Air", platform: "macOS", detail: "局域网来源 · 24 ms" },
];

const presets = [
  { name: "游戏 + 学习", route: "手机 → Windows → 2.4G 耳机" },
  { name: "图书馆", route: "Mac → Android → 蓝牙耳机" },
];

export function BlueBridgeApp() {
  const [view, setView] = useState<View>("route");
  const [running, setRunning] = useState(true);
  const [toast, setToast] = useState("");
  const [volumes, setVolumes] = useState([82, 64, 72]);
  const [muted, setMuted] = useState([false, false, false]);
  const [settings, setSettings] = useState([true, true, true]);

  useEffect(() => {
    if (!toast) return;
    const timer = window.setTimeout(() => setToast(""), 2200);
    return () => window.clearTimeout(timer);
  }, [toast]);

  const pageTitle = nav.find((item) => item.id === view)?.label ?? "音频路由";

  function startPreset(name: string) {
    setRunning(true);
    setView("route");
    setToast(`“${name}”已启动`);
  }

  return (
    <div className="shell">
      <aside className="sidebar">
        <div className="brand">BlueBridge</div>
        <nav aria-label="主导航">
          {nav.map((item) => (
            <button className={view === item.id ? "active" : ""} key={item.id} onClick={() => setView(item.id)} type="button">
              <span>{item.number}</span>{item.label}
            </button>
          ))}
        </nav>
        <div className="privacy"><strong>仅在本地处理</strong><small>音频不会上传到云端</small></div>
      </aside>

      <main>
        <header>
          <div><h1>{pageTitle}</h1><p>来源、目标、输出和状态集中显示</p></div>
          <span className="status"><i />3 台设备在线</span>
        </header>

        {view === "route" && (
          <>
            <section className="card current-route">
              <div className="card-head">
                <div><small>当前路由</small><h2>游戏 + 学习</h2></div>
                <button className="primary" onClick={() => { setRunning(!running); setToast(running ? "路由已停止，配置已保留" : "路由已恢复"); }} type="button">{running ? "停止" : "恢复"}</button>
              </div>
              <div className="route-flow">
                <RouteNode number="01" label="来源" value="Pixel 9 · 媒体" />
                <b>→</b>
                <RouteNode number="02" label="目标" value="本机 Windows" />
                <b>→</b>
                <RouteNode number="03" label="输出" value="2.4G 耳机" />
              </div>
              <div className="route-meta">
                <span className={running ? "online" : ""}>{running ? "运行中" : "已暂停"}</span>
                <span>标准蓝牙</span><span>18 ms</span><span>48 kHz · 24 bit</span>
              </div>
            </section>

            <section className="card">
              <SectionTitle title="新建路由" detail="选择来源、目标和输出设备" />
              <div className="route-form">
                <Field label="音频来源" options={["Pixel 9 · 媒体", "本机 · 游戏", "MacBook Air · 系统音频"]} />
                <Field label="目标设备" options={["本机 Windows", "Pixel 9", "MacBook Air"]} />
                <Field label="输出设备" options={["2.4G 耳机", "USB DAC", "系统扬声器"]} />
                <button className="primary" onClick={() => { setRunning(true); setToast("路由已启动"); }} type="button">启动</button>
              </div>
            </section>

            <section>
              <SectionTitle title="混音" detail="每一路声音可独立调整" />
              <div className="list card">
                {["本机 · 游戏", "Pixel 9 · 媒体", "Discord · 语音"].map((name, index) => (
                  <div className="mixer-row" key={name}>
                    <div><strong>{name}</strong><small>{["WASAPI 本地路径", "标准蓝牙", "应用捕获"][index]}</small></div>
                    <input aria-label={`${name}音量`} type="range" min="0" max="100" value={volumes[index]} onChange={(event) => setVolumes((values) => values.map((value, i) => i === index ? Number(event.target.value) : value))} />
                    <output>{volumes[index]}%</output>
                    <button className="secondary" aria-pressed={muted[index]} onClick={() => setMuted((values) => values.map((value, i) => i === index ? !value : value))} type="button">{muted[index] ? "取消静音" : "静音"}</button>
                  </div>
                ))}
              </div>
            </section>

            <section>
              <SectionTitle title="可信设备" detail="附近且可以自动重连" />
              <DeviceList />
            </section>
          </>
        )}

        {view === "devices" && (
          <section>
            <div className="section-head"><SectionTitle title="设备列表" detail="首次连接需要在两台设备上确认" /><button className="primary" onClick={() => setToast("正在扫描附近设备")}>扫描设备</button></div>
            <DeviceList />
          </section>
        )}

        {view === "presets" && (
          <section>
            <SectionTitle title="场景" detail="一键恢复来源、输出和音量" />
            <div className="preset-list">
              {presets.map((preset) => <article className="card preset" key={preset.name}><div><h2>{preset.name}</h2><p>{preset.route}</p></div><button className="primary" onClick={() => startPreset(preset.name)}>启动</button></article>)}
            </div>
          </section>
        )}

        {view === "settings" && (
          <section>
            <SectionTitle title="设置" detail="连接与恢复行为" />
            <div className="list card">
              {["自动重连", "自动选择最佳链路", "音频回环保护"].map((name, index) => (
                <div className="setting-row" key={name}><strong>{name}</strong><button className={`switch ${settings[index] ? "on" : ""}`} aria-pressed={settings[index]} onClick={() => setSettings((values) => values.map((value, i) => i === index ? !value : value))}><span /></button></div>
              ))}
            </div>
          </section>
        )}
      </main>

      <nav className="mobile-nav" aria-label="移动导航">
        {nav.map((item) => <button className={view === item.id ? "active" : ""} key={item.id} onClick={() => setView(item.id)}><span>{item.number}</span>{item.label}</button>)}
      </nav>
      {toast && <div className="toast" role="status">{toast}</div>}
    </div>
  );
}

function RouteNode({ number, label, value }: { number: string; label: string; value: string }) {
  return <div className="route-node"><small>{number}&nbsp;&nbsp;{label}</small><strong>{value}</strong></div>;
}

function SectionTitle({ title, detail }: { title: string; detail: string }) {
  return <div className="section-title"><h2>{title}</h2><p>{detail}</p></div>;
}

function Field({ label, options }: { label: string; options: string[] }) {
  return <label><span>{label}</span><select>{options.map((option) => <option key={option}>{option}</option>)}</select></label>;
}

function DeviceList() {
  return <div className="list card">{devices.map((device) => <div className="device-row" key={device.name}><div><strong>{device.name}</strong><small>{device.platform} · {device.detail}</small></div><span className="online">在线</span></div>)}</div>;
}
