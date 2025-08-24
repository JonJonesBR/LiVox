/** @type {import('next').NextConfig} */
const nextConfig = {
  // Configuração para servir assets corretamente
  assetPrefix: process.env.NODE_ENV === 'production' ? '' : '',
  // Remover output standalone para desenvolvimento
  // output: 'standalone',
};

module.exports = nextConfig;