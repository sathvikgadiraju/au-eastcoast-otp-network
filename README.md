# au-eastcoast-otp-network

OpenTripPlanner 2.6 multimodal routing network for Australia's east coast (Melbourne–Canberra–Sydney–Newcastle). Built for the ARC Discovery Project *"Discovering the sustainable size of cities"* to support high-speed rail demand modelling and intercity accessibility analysis.

## Overview

This repository contains the configuration, GTFS feeds, and scripts needed to build and run an OTP routing server covering the Australian east-coast corridor. The network supports schedule-based multimodal routing across rail, bus, tram, ferry, domestic flights, and intercity coaches — with fares attached to all modes.

## Corridor coverage

| City | Role |
|------|------|
| Melbourne | Southern terminus |
| Canberra | Intermediate city |
| Sydney | Major hub |
| Newcastle | Northern terminus |

## Modes included

- **Rail** — NSW TrainLink intercity (XPT), V/Line regional, Sydney Trains, Sydney Metro, Melbourne metro
- **Bus/Tram** — NSW and VIC metropolitan and regional bus, Melbourne tram
- **Ferry** — Sydney Ferries
- **Domestic flights** — Qantas, Jetstar, Virgin, Rex (14 airports)
- **Intercity coach** — Firefly, Greyhound, Murrays, Premier Motor Service
- **Airport access** — SkyBus Melbourne

## Data sources

| Feed | Source | Licence |
|------|--------|---------|
| NSW GTFS | Transport for NSW Open Data | CC BY 4.0 |
| VIC GTFS (8 sub-feeds) | PTV / data.vic.gov.au | CC BY 4.0 |
| Flights GTFS | AviationStack API + project build | Project internal |
| Private coaches GTFS | Operator timetables + project build | Project internal |
| OSM road network | OpenStreetMap contributors | ODbL |

**Note:** The full NSW GTFS feed (~291 MB) exceeds GitHub's file size limit. The `gtfs_NSW_202605130001.zip` in this repository contains only the fare files (`fare_attributes.txt`, `fare_rules.txt`). The complete feed is available from [Transport for NSW Open Data](https://opendata.transport.nsw.gov.au/).

## Reference day

All services are parameterised for **Wednesday 20 May 2026** — a neutral weekday at the 65th percentile of historical corridor demand, in a clean calendar window with no public holidays or major events.

## Requirements

- Java 21+
- OTP 2.6.0 shaded JAR (~100 MB, not included — download from [OTP releases](https://github.com/opentripplanner/OpenTripPlanner/releases))
- 10–16 GB RAM for graph build
- 4 GB RAM for server operation

## Quick start

```powershell
# 1. Build the graph (first time only)
.\build_graph.ps1 -MaxMemoryGb 16

# 2. Start the server
.\run_otp.ps1

# 3. Access the routing interface
# Web UI:    http://localhost:8080/
# GraphQL:   http://localhost:8080/otp/gtfs/v1
```

## Querying fares

Fares are encoded as GTFS Fares V1 and returned per leg via the GraphQL API. Use an inline fragment to access the price:

```graphql
{
  plan(from: {lat: -37.81, lon: 144.96}, to: {lat: -33.87, lon: 151.21},
       date: "2026-05-20", time: "08:00",
       transportModes: [{mode: TRANSIT}, {mode: WALK}]) {
    itineraries {
      legs {
        mode
        route { shortName }
        fareProducts {
          product {
            name
            ... on DefaultFareProduct {
              price { amount currency { code } }
            }
          }
        }
      }
    }
  }
}
```

## Project context

This network serves as the supply-side input to a Land Use and Transport Interaction (LUTI) model evaluating how high-speed rail affects population distribution and travel demand across Australia's east-coast cities. It provides the generalised cost matrices (time + fare + transfers) between SA2 zone centroids that drive gravity-based demand models and accessibility indices.

## Authors

Saeid Nazari Adli — Monash University, Department of Civil Engineering

## Licence

See [LICENSE](LICENSE).
