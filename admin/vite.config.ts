import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

// https://vite.dev/config/
export default defineConfig({
  plugins: [react()],
  base: '/admin/',
  build: {
    rolldownOptions: {
      output: {
        codeSplitting: {
          groups: [
            {
              name: 'react-vendor',
              test: /node_modules[\\/]react/,
              priority: 20,
            },
            {
              name: 'ui-vendor',
              test: /node_modules[\\/]\@mui/,
              priority: 15,
            },
            {
              name: 'vendor-admin',
              test: /node_modules[\\/]react-admin/,
              priority: 12,
            },
            {
              name: 'vendor',
              test: /node_modules/,
              priority: 10,
            },
            {
              name: 'common',
              minShareCount: 2,
              minSize: 10000,
              priority: 5,
            },
          ],
        },
      },
    }
  }
})
