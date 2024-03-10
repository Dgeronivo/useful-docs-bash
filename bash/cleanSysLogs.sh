#!/bin/bash

journalctl --disk-usage

sudo journalctl --vacuum-size=50M && sudo journalctl --verify

journalctl --disk-usage
