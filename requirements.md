# Project _McDebugin_
A simple, hand-held modern alternative to the venerable Fluke 9010A Micro-System Troubleshooter.

# Requirements

## Physical Dimensions
| Specification | Value | Notes |
|----------|-------------|------|
| Product | Approximately 4"W x 10"L x 2"T| - |
| Pod | Approximately 3"W x 1"L| - |
| Display | Less than 3" |https://www.adafruit.com/product/4694 https://www.adafruit.com/product/2674 https://www.adafruit.com/product/1774 https://www.adafruit.com/product/198 |

## Interfaces
| Specification | Value | Notes |
|----------|-------------|------|
| Power | DC Input < 10W, power switch, indicator | Battery optional |
| SD Card | Size TBD | Minimum size for programming file |
| Keypad | Numbers 0x0-0xF, _enter_ key, 4+ Function | mechanical preferred |
| Probe | Standard bayonet coax | oscilloscope compatible |
| CPU Connection | Depends on TBD Pod architecture | 6-40 connections |
| LEDs | General Use | Minimum 4: unit power, target power, SD access, target clock lock |

## Pod
| Specification | Value | Notes |
|----------|-------------|------|
| Target Board Connection | machined headers, requires socket on target board | - |
| Supported CPUs | Z80, 6502, 6809 (40-pin DIP) | Other pinouts possible |
| Supported Clock Rates | < 20MHz | - |
| Bidirectional Pins | All IO pins | 8-bit bus typical |

## Features
| Specification | Value | Notes |
|----------|-------------|------|
| Clock detection | Detects clock from target board and reports frequency/variation | - |
| TBD | TBD | - |
| TBD | TBD | - |
| TBD | TBD | - |
| TBD | TBD | - |
| TBD | TBD | - |