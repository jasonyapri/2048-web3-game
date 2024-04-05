/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    "./pages/**/*.{js,ts,jsx,tsx,mdx}",
    "./components/**/*.{js,ts,jsx,tsx,mdx}",
    "./app/**/*.{js,ts,jsx,tsx,mdx}",
  ],
  theme: {
    extend: {
      backgroundImage: {
        "gradient-radial": "radial-gradient(var(--tw-gradient-stops))",
        "gradient-conic":
          "conic-gradient(from 180deg at 50% 50%, var(--tw-gradient-stops))",
      },
      padding: {
        'wallet-balance-bottom': '8px',
        'wallet-balance-horizontal': '22.5px',
        'wallet-balance-top': '5px',
      },
      colors: {
        'theme-primary-background': '#0A0F1B',
        'theme-primary': '#1486F2',
        'theme-primary-light': '#79BAF8',
        'theme-secondary': '#FDC801',
        'theme-red': '#D01D1D',
        'theme-light-grey': '#D2D2D2',
      },
      borderWidth: {
        '1': '1px',
      }
    },
  },
  plugins: [
    require('@tailwindcss/nesting'),
  ],
};
