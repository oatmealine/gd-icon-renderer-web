# gd-icon-renderer-web

A server-side renderer API for Geometry Dash icons, made with [gd-icon-renderer](https://github.com/oatmealine/gd-icon-renderer)

| ![](https://gdicon.oat.zone/icon.png?type=cube&value=181&color1=8&color2=70) |
| :---: |
| Result given the input `/icon.png?type=cube&value=181&color1=8&color2=70`           |

## Usage

`https://gdicon.oat.zone/icon.png?type=cube&value=181&color1=8&color2=70`

`color1` and `color2` can accept numeric color values or hex color strings; file format is not limited to `png`, can be `webp`, `jpg`, etc.

## Self-hosting

### Installation

0. You'll need [`libvips`](https://www.libvips.org/) (and its development packages, for compilation) as well as [the Crystal compiler](https://crystal-lang.org/) on your machine. Get those from your package manager; I'm sure you know how.

1. Clone the repo:
    ```sh
    git clone https://github.com/oatmealine/gd-icon-renderer-web
    ```
2. Install dependencies:
    ```sh
    shards install
    ```
3. Build:
    ```sh
    shards build
    ```

### Usage

1. Fill out the info in `.env.example` (into `.env`) as necessary
2. Put the following files from your Geometry Dash resources folder into `data/` (create if it doesn't exist):
    ```
    icons/*-uhd.*
    Robot_AnimDesc.plist
    Spider_AnimDesc.plist
    ```
3. Run `bin/gd-icon-renderer-web` (or `shards run` for development environments)
