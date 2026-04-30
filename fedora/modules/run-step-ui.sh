#!/usr/bin/env bash

if [[ -n "${RUN_STEP_UI_SH_LOADED:-}" ]]; then
  return 0
fi
RUN_STEP_UI_SH_LOADED=1

if command -v tput >/dev/null 2>&1; then
  BOLD="$(tput bold)"
  BLUE="$(tput setaf 4)"
  YELLOW="$(tput setaf 3)"
  GREEN="$(tput setaf 2)"
  RED="$(tput setaf 1)"
  DARK_GREY="$(tput setaf 8)"
  LIGHT_GREY="$(tput setaf 7)"
  RESET="$(tput sgr0)"
else
  BOLD=""
  BLUE=""
  YELLOW=""
  GREEN=""
  RED=""
  DARK_GREY=""
  LIGHT_GREY=""
  RESET=""
fi

print_header() {
  local title="$1"
  local description="${2:-}"
  local author="${3:-}"
  local width
  local width_content
  local left_pad

  if command -v tput >/dev/null 2>&1; then
    width=$(tput cols)
  else
    width=80
  fi

  width_content=$(( width * 2 / 3 ))
  left_pad=$(( (width - width_content) / 2 ))

  printf "\n${BLUE}%*s${RESET}\n" "$width" "" | tr ' ' '='
  print_centered_wrapped "$title" "${BOLD}" "$width_content" "$left_pad"
  print_centered_wrapped "$description" "${DARK_GREY}" "$width_content" "$left_pad"
  print_centered_wrapped "$author" "${DARK_GREY}" "$width_content" "$left_pad"
  printf "${BLUE}%*s${RESET}\n\n" "$width" "" | tr ' ' '='
}

print_centered_wrapped() {
  local text="$1"
  local style="$2"
  local width_content="$3"
  local left_pad="$4"
  local line
  local line_pad

  [[ -z "$text" ]] && return

  while IFS= read -r line; do
    line_pad=$(( left_pad + (width_content - ${#line}) / 2 ))
    (( line_pad < left_pad )) && line_pad=$left_pad
    printf "%s%*s%s%s\n" "$style" "$line_pad" "" "$line" "$RESET"
  done < <(printf "%s\n" "$text" | fold -w "$width_content")
}

print_section() {
  local text="$1"
  echo -e "\n${BOLD}▶  ${text}${RESET}\n"
}

run_step() {
  local label="$1"
  shift

  local log_file
  log_file="$(mktemp)"

  printf "\r${YELLOW}⏳ %s...${RESET}" "$label"

  if "$@" >"$log_file" 2>&1; then
    printf "\r\033[K"
    printf "${GREEN}✔  %s${RESET}\n" "$label"
    rm -f "$log_file"
    return 0
  fi

  printf "\r\033[K"
  printf "${RED}${BOLD}✖  %s${RESET}\n" "$label"
  echo "${RED}Detalle del error:${RESET}"
  tail -n 40 "$log_file" || true
  rm -f "$log_file"
  return 1
}
