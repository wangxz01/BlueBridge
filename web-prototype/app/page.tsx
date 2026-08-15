import type { Metadata } from "next";
import { BlueBridgeApp } from "./BlueBridgeApp";

export const metadata: Metadata = {
  title: "BlueBridge — One headset. Every device.",
  description:
    "在 Windows、macOS 与 Android 之间发现设备、创建音频路由并一键启动场景。",
};

export default function Home() {
  return <BlueBridgeApp />;
}
