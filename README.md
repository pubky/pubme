# PubMe: A Decentralized Publishing Tool

![PubMe Screenshot](https://github.com/pubky/pubme/blob/main/screenshot.png)

## Overview

PubMe is a decentralized publishing tool that allows users to publish and manage content without relying on centralized servers. It leverages the Pubky Core protocol to enable censorship-resistant publishing, ensuring content availability and privacy for users.

## Features

- **Decentralized Content Publishing**: Publish articles, media, and other types of content in a censorship-resistant manner.
- **Identity Management**: Manage user identities using PKARR to ensure secure and decentralized ownership of content.
- **Cross-Platform Compatibility**: PubMe is compatible across multiple platforms and devices.

## Technology Stack

- **Programming Languages**: JavaScript, Node.js
- **Pubky Core Integration**: Built on top of the Pubky Core protocol for decentralized data handling.
- **Frontend Framework**: React.js for user interface components.
- **Backend**: Node.js for handling server-side functionality.

## Prerequisites

- **Node.js**: Version 14.x or above.
- **npm**: Version 6.x or above.
- **Pubky Developer Account**: Obtain an API key from the Pubky developer portal.

Ensure these prerequisites are installed before proceeding with setup.

## Installation

1. Clone the repository:

   ```sh
   git clone https://github.com/synonym-to/pubme.git
   ```

2. Navigate to the project directory:

   ```sh
   cd pubme
   ```

3. Install dependencies:

   ```sh
   npm install
   ```

4. Create an environment configuration file by copying the example:

   ```sh
   cp .env.example .env
   ```

5. Update the `.env` file with your configuration details:

   - `PUBKY_API_KEY`: The API key for Pubky Core.
   - `HOMESERVER_URL`: URL of the homeserver for data synchronization.
   - `PKARR_ENDPOINT`: Endpoint for managing PKARR services.

## Usage

### Running the Development Server

To start the development server, run:

```sh
npm run dev
```

This will start a local instance of the PubMe tool for testing and development.

### Building for Production

To build the application for production, run:

```sh
npm run build
```

After building, you can start the production server with:

```sh
npm run start
```

## Contribution

We welcome contributions from the community. If you're interested in contributing, please fork the repository, create a branch, and submit a pull request.

## License

This project is licensed under the MIT License. See the LICENSE file for more information.

## Community and Support

Join our community to stay up-to-date with the latest news and developments:

- [Twitter X Updates](https://x.com/getpubky)
