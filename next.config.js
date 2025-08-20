/** @type {import('next').NextConfig} */
const nextConfig = {
  // Removido assetPrefix que estava causando problemas com CSS
  experimental: {
    appDir: true,
  },
};

module.exports = nextConfig;
