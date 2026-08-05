# Project Brief: ChessClock Mobile App

## Project Overview
ChessClock is a specialized utility app designed for chess players who need a reliable, high-fidelity digital clock for over-the-board play. The app replicates the functionality and aesthetics of professional chess timers while providing a seamless mobile-first experience.

## Goal
To provide a clean, intuitive, and highly functional chess clock that supports standard time controls, custom settings, and "time odds" variants, with full support for both light and dark modes.

## Core Features
- **Splash Screen**: A minimalist entry point featuring the brand identity.
- **Flexible Time Controls**:
  - Predefined categories: Bullet, Blitz, Rapid, and Daily.
  - Custom Setup: Precise minute and increment adjustments.
  - **Time Odds**: A specialized mode allowing different starting times for Player 1 (White) and Player 2 (Black).
- **Dual-Theme Support**: Instant switching between Light and Dark modes to suit player preference and environment.
- **Active Game Interface**:
  - Split-screen layout for two players.
  - Large, high-contrast timers.
  - Centralized pause mechanism with an exit/confirmation menu.

## Visual Identity & Design System
The app follows a modern, professional aesthetic inspired by competitive chess platforms.

- **Primary Color**: Blue (#135bec) for actions and active states.
- **Success State**: Green (#22c55e) for active turns.
- **Warning State**: Yellow (#eab308) for low time.
- **Critical State**: Red (#ef4444) for time expiration.
- **Surfaces (Dark)**: Deep navy/charcoal (#101622) for background with layered cards (#1c232e).
- **Surfaces (Light)**: High-contrast white and light gray backgrounds.

## Screen Inventory
1. **Splash Screen**: Initial brand loading state.
2. **Setup Screen (Light/Dark)**: The main configuration hub for selecting time controls.
3. **Active Clock Screen**: The gameplay interface with dual timers and pause controls.
4. **Design System Reference**: Documentation of the color palette and UI components.

## Technical Requirements
- **Responsive Layout**: Optimized for mobile devices in portrait orientation.
- **State Management**: Real-time countdown logic with millisecond precision for blitz/bullet.
- **Interactivity**: Large tap targets for the clocks to ensure reliability during fast play.
