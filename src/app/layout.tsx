import type { Metadata } from "next";
import { Inter } from "next/font/google";
import "./globals.css";

const inter = Inter({
  subsets: ["latin"],
  variable: "--font-inter",
  display: "swap",
});

export const metadata: Metadata = {
  title: "VA Backend - Production Ready Next.js Application",
  description:
    "Enterprise-scale Next.js application with TypeScript, Tailwind CSS, and best practices",
  keywords: ["Next.js", "TypeScript", "Tailwind CSS", "Enterprise"],
  authors: [{ name: "VA Backend Team" }],
  creator: "VA Backend",
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>): React.ReactElement {
  return (
    <html lang="en" suppressHydrationWarning>
      <body className={`${inter.variable} font-sans antialiased`}>
        {children}
      </body>
    </html>
  );
}
