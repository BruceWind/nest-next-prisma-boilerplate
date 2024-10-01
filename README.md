# 🎏 NestJS - NextJS - tRPC - Prisma stack app

## 🍰 Tech stack

- DB: PostgreSQL (dockerized)
- ORM: Prisma
- Node.js framework: NestJS
- End-to-end type-safe APIs: [tRPC](https://trpc.io/)
- Frontend: NextJS
- Style: Tailwind + [daisyUI](https://daisyui.com/)
- Node.js package manager: [pnpm](https://pnpm.io)
- Monorepo: [pnpm workspace](https://pnpm.io/workspaces)
- Containerization: Docker

## 🥕 Getting Started

Update [pnpm](https://pnpm.io):

```sh
pnpm i -g pnpm
```

Develop:

```sh
# create local environment variables
cp ./apps/web/.env.local.example ./apps/web/.env.local

# Optionally, modify the conf.ini file to change database settings

# Start the Docker containers
docker-compose up --build
```

Following this, you can open:
- `http://localhost:3000` in your browser for the NextJS app
- `http://localhost:4000` for the NestJS server
- `http://localhost:5555` for Prisma Studio

If you want to install the `@nestjs/config` package. In the root of your directory, you can run:

```sh
pnpm add @nestjs/config --filter=server
```

## Deployment

This repo has been tested to run with railway.
You can fork and open railway to establish:
[deploy on railway](https://railway.app)

## Database Backup and Restore

To backup the PostgreSQL database:

```sh
docker run --rm -v postgres_data:/dbdata -v $(pwd):/backup alpine tar cvf /backup/backup.tar /dbdata
```

To restore the PostgreSQL database:

```sh
docker run --rm -v postgres_data:/dbdata -v $(pwd):/backup alpine sh -c "cd /dbdata && tar xvf /backup/backup.tar --strip 1"
```

## 🧚‍♀️ Reference

- [Building a full-stack, fully type-safe pnpm monorepo with NestJS, NextJS & tRPC](https://www.tomray.dev/nestjs-nextjs-trpc)
- [nestjs-prisma](https://www.tomray.dev/nestjs-prisma)

### More docs in this repo

[server/Readme](/apps/server/README.md)

[web/Readme](/apps/web/README.md)

## Configuration

The project uses a `conf.ini` file in the root directory to set variables for Docker building. You can modify this file to change database settings and other environment variables.
