function download_erlang() {
  # erlang_package_url="https://github.com/elixir-buildpack/heroku-otp/releases/download"
  # erlang_package_url="${erlang_package_url}/${erlang_version}/${STACK}.tar.gz"
  erlang_package_url="https://s3.amazonaws.com/heroku-buildpack-elixir/erlang/cedar-14"
  erlang_package_url="${erlang_package_url}/OTP-${erlang_version}.tar.gz"

  # If a previous download does not exist, then always re-download
  if [ ! -f "$(erlang_download_path)/${erlang_version}/${STACK}.tar.gz" ]; then
    clean_erlang_downloads

    # Set this so elixir will be force-rebuilt
    erlang_changed=true

    output_section "Fetching Erlang ${erlang_version} from ${erlang_package_url}"
    curl -L -s ${erlang_package_url} -o "$(erlang_download_path)/${erlang_version}/${STACK}.tar.gz" || exit 1
  else
    output_section "Using cached Erlang ${erlang_version}"
  fi
}

function clean_erlang_downloads() {
  rm -rf $(erlang_download_path)
  mkdir -p "$(erlang_download_path)/${erlang_version}"
}

function install_erlang() {
  output_section "Installing Erlang ${erlang_version} $(erlang_changed)"

  rm -rf $(erlang_build_path)
  mkdir -p $(erlang_build_path)
  tar zxf "$(erlang_download_path)/${erlang_version}/${STACK}.tar.gz" -C $(erlang_build_path) --strip-components=1

  rm -rf $(runtime_erlang_path)
  mkdir -p $(runtime_platform_tools_path)
  ln -s $(erlang_build_path) $(runtime_erlang_path)
  $(erlang_build_path)/Install -minimal $(runtime_erlang_path)

  cp -R $(erlang_build_path) $(erlang_path)
  PATH=$(erlang_path)/bin:$PATH
}

function erlang_changed() {
  if [ $erlang_changed = true ]; then
    echo "(changed)"
  fi
}
