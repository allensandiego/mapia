#!/bin/bash
# Fix RPM spec files to make icon and desktop file copies optional

find dist -name "*.spec" -type f | while read spec_file; do
  echo "Patching $spec_file..."
  
  # Make cp -r mapia.png optional
  sed -i 's/^cp -r %{name}\.png %/cp -r %{name}.png %{buildroot}%{_datadir}\/pixmaps || :\n# original: cp -r %{name}.png %/' "$spec_file" || true
  
  # Alternative: just add || : to the line
  sed -i '/^cp -r %{name}\.png /s/$/ || :/' "$spec_file" || true
  sed -i '/^cp -r %{name}\.desktop /s/$/ || :/' "$spec_file" || true
  
  echo "Patched $spec_file"
done
