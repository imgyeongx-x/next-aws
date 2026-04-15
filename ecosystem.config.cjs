module.exports = {
  apps: [
    {
      name: 'next-aws',
      script: '/var/www/next-aws/current/server.js',
      cwd: '/var/www/next-aws/current',
      instances: 1,
      exec_mode: 'fork',
      env: {
        NODE_ENV: 'production',
        PORT: 3000,
      },
    },
  ],
};