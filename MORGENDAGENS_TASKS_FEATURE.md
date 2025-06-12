# Morgendagens Tasks Feature

Jeg har implementert en komplett feature som lar brukere se og administrere morgendagens tasks etter en split. Her er en oversikt over implementasjonen:

## Implementerte Komponenter

### 1. Tasks Context - Ny Funksjon
**Fil:** `lib/daily_task/tasks.ex`

Lagt til en ny funksjon `get_task_by_tomorrow/0` som:
- Beregner morgendagens dato automatisk
- Henter tasken for morgendagens dato fra databasen
- Returnerer `nil` hvis ingen task finnes

```elixir
def get_task_by_tomorrow do
  tomorrow = Date.add(Date.utc_today(), 1)
  get_task_by_date(tomorrow)
end
```

### 2. Tomorrow LiveView
**Fil:** `lib/daily_task_web/live/task_live/tomorrow.ex`

En komplett LiveView-modul som håndterer:
- Visning av morgendagens task
- Redigering av morgendagens task
- Oppretting av nye tasks for i morgen
- Sletting og fullføring av morgendagens tasks
- Navigasjon tilbake til dagens tasks

### 3. Tomorrow HTML Template
**Fil:** `lib/daily_task_web/live/task_live/tomorrow.html.heex`

En HTML-template på norsk som inkluderer:
- Visning av morgendagens task med dato
- Knapper for å fullføre, redigere og slette
- Melding når ingen task finnes for i morgen
- Knapp for å legge til ny task for i morgen
- Navigasjonslenke tilbake til dagens tasks

### 4. Router-oppdateringer
**Fil:** `lib/daily_task_web/router.ex`

Nye ruter lagt til:
- `/tasks/tomorrow` - hovedside for morgendagens tasks
- `/tasks/tomorrow/new` - ny task for i morgen
- `/tasks/tomorrow/:id/edit` - rediger morgendagens task

### 5. Navigasjon fra Dagens Tasks
**Fil:** `lib/daily_task_web/live/task_live/index.html.heex`

Lagt til en navigasjonsknapp på dagens task-side som lenker til morgendagens tasks:
```html
<.link navigate={~p"/tasks/tomorrow"} class="inline-flex items-center px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors">
  Se morgendagens tasks →
</.link>
```

### 6. Forbedret Split-funksjonalitet
**Fil:** `lib/daily_task_web/live/task_live/index.ex`

Oppdatert flash-meldingen når en task blir splittet:
```elixir
|> put_flash(:info, "Task splittet! Se morgendagens tasks for å se den andre delen.")
```

### 7. Tester
**Filer:** 
- `test/daily_task/tasks_test.exs` - tester for `get_task_by_tomorrow/0`
- `test/daily_task_web/live/task_live_tomorrow_test.exs` - komplett testsuite for Tomorrow LiveView

## Funksjonalitet

### Brukerflyt
1. **Fra dagens tasks:** Brukeren kan klikke "Se morgendagens tasks →" for å navigere til morgendagens side
2. **Visning:** Hvis det finnes en task for i morgen, vises den med alle detaljer
3. **Ingen task:** Hvis ingen task finnes, vises en melding og knapp for å lage ny task
4. **Administrasjon:** Brukeren kan fullføre, redigere eller slette morgendagens task
5. **Navigasjon:** Enkel tilbakenavigasjon til dagens tasks

### Split-integrasjon
- Når en task blir splittet, opprettes automatisk en task for i morgen
- Brukeren får en informativ melding som oppfordrer til å sjekke morgendagens tasks
- Den nye morgendagens task er umiddelbart tilgjengelig på `/tasks/tomorrow`

### Tekst på Norsk
Hele brukergrensesnittet er på norsk som forespurt:
- "Morgendagens task"
- "Ingen task for i morgen ennå"
- "Legg til task for i morgen"
- "Fullfør", "Rediger", "Slett"
- "Tilbake til dagens tasks"

## Teknisk Implementasjon

### Kodekvalitet
- Følger eksisterende kodestil og mønstre
- Gjenbruker FormComponent for konsistens
- Proper error handling og flash-meldinger
- Responsive design med Tailwind CSS

### Testing
- Unit-tester for Tasks context-funksjonen
- Integration-tester for LiveView-funksjonaliteten
- Tester for alle CRUD-operasjoner
- Tester for navigasjon og brukerinteraksjon

### Sikkerhet og Robusthet
- Sikker dato-håndtering med Elixir Date-modulen
- Proper validering gjennom eksisterende changeset-logikk
- Konsistent error handling

## Bruk

For å bruke den nye featureen:

1. **Start applikasjonen:** `mix phx.server`
2. **Gå til dagens tasks:** `/tasks`
3. **Split en task** eller **naviger direkte til morgendagens tasks:** `/tasks/tomorrow`
4. **Administrer morgendagens tasks** som ønsket

Featureen integreres sømløst med eksisterende funksjonalitet og følger de samme designprinsippene som resten av applikasjonen.