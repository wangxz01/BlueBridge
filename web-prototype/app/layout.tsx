import type { Metadata } from "next";
import { Geist, Geist_Mono } from "next/font/google";
import "./globals.css";

const geistSans = Geist({
  variable: "--font-geist-sans",
  subsets: ["latin"],
});

const geistMono = Geist_Mono({
  variable: "--font-geist-mono",
  subsets: ["latin"],
});

export const metadata: Metadata = {
  title: {
    default: "BlueBridge｜跨设备音频路由",
    template: "%s · BlueBridge",
  },
  description:
    "跨 Windows、macOS 与 Android 的个人音频路由控制中心。所有音频留在本地。",
  applicationName: "BlueBridge",
  openGraph: {
    title: "BlueBridge｜跨设备音频路由",
    description: "来源、目标、输出和状态，集中显示。",
    type: "website",
    images: [{ url: "/og-minimal.png", width: 1536, height: 1024 }],
  },
  twitter: {
    card: "summary_large_image",
    title: "BlueBridge｜跨设备音频路由",
    description: "来源、目标、输出和状态，集中显示。",
    images: ["/og-minimal.png"],
  },
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="zh-CN">
      <body className={`${geistSans.variable} ${geistMono.variable}`}>
        {children}
      </body>
    </html>
  );
}
