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
    default: "BlueBridge — One headset. Every device.",
    template: "%s · BlueBridge",
  },
  description:
    "跨 Windows、macOS 与 Android 的个人音频路由控制中心。所有音频留在本地。",
  applicationName: "BlueBridge",
  openGraph: {
    title: "BlueBridge — One headset. Every device.",
    description: "One headset. Every device. 让每台设备的声音，在一副耳机里相遇。",
    type: "website",
    images: [{ url: "/og.png", width: 1536, height: 1024 }],
  },
  twitter: {
    card: "summary_large_image",
    title: "BlueBridge — One headset. Every device.",
    description: "跨平台个人音频路由器，让每台设备的声音在一副耳机里相遇。",
    images: ["/og.png"],
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
