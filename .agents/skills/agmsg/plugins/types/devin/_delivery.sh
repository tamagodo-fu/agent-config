#!/usr/bin/env bash
# devin delivery plug — rule-file integration (same shape as gemini/antigravity).
# Devin's own always-on rule directory is .windsurf/rules/*.md (confirmed via
# `devin rules paths`), which is what type.conf's hooks_file= points at.
# rulefile_apply/rulefile_status are provided by scripts/lib/delivery-rulefile.sh,
# which delivery.sh sources before any type plug.
agmsg_delivery_apply() { rulefile_apply "$@"; }
agmsg_delivery_status() { rulefile_status "$@"; }
