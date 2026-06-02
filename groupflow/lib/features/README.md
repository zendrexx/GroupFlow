# Tasks Feature

Architecture:
- Clean Architecture
- MVVM
- Riverpod

Flow:

UI
↓
Page
↓
ViewModel
↓
UseCase
↓
Repository Contract
↓
Repository Implementation
↓
Datasource
↓
Supabase/API

Structure:

tasks/
├── domain/
├── data/
└── presentation/

Dependency Rule:

Presentation → Domain
Data → Domain

Domain depends on nothing.