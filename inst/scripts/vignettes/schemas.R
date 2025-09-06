reactable_schema <- function(dat, ...) {
  # button click handlers
  js_code <- "
  function toggleSchema(rowId, versionIndex) {
    var schemaId = 'schema_' + rowId + '_' + versionIndex;
    var buttonId = 'btn_' + rowId + '_' + versionIndex;
    var schemaDiv = document.getElementById(schemaId);
    var button = document.getElementById(buttonId);

    if (schemaDiv && button) {
      if (schemaDiv.style.display === 'none' || schemaDiv.style.display === '') {
        // Show schema, change button to active state
        schemaDiv.style.display = 'block';
        button.style.backgroundColor = '#1565c0';
        button.style.color = 'white';
        button.style.borderColor = '#0d47a1';
        button.style.transform = 'scale(0.98)';
      } else {
        // Hide schema, reset button to normal state
        schemaDiv.style.display = 'none';
        button.style.backgroundColor = '#e3f2fd';
        button.style.color = '#1565c0';
        button.style.borderColor = '#90caf9';
        button.style.transform = 'scale(1)';
      }
    }
}
  "

  htmltools::tags$div(
    htmltools::tags$script(HTML(js_code)),
    reactable::reactable(
      dat,
      sortable = TRUE,
      searchable = TRUE,
      pagination = FALSE,
      filterable = TRUE,
      striped = TRUE,
      highlight = TRUE,
      bordered = TRUE,
      theme = reactable::reactableTheme(
        borderColor = "#dfe2e5",
        stripedColor = "#f8f9fa",
        highlightColor = "#f0f5ff",
        cellPadding = "12px 15px"
      ),
      columns = list(
        n = reactable::colDef(maxWidth = 70),
        row_id = reactable::colDef(show = FALSE),
        schema_version = reactable::colDef(
          minWidth = 130,
          name = "Schema",
          html = TRUE,
          cell = function(value, index) {
            row_id <- dat$row_id[[index]]
            versions <- value$version

            # Create interactive version buttons
            version_buttons <- purrr::map_chr(
              seq_along(versions),
              function(i) {
                v <- versions[[i]]
                button_id <- glue("btn_{row_id}_{i - 1}")
                paste0(
                  glue('<button id="{button_id}" onclick="toggleSchema({row_id}, {i - 1})" '),
                  'style="',
                  'background-color: #e3f2fd; ',
                  'border: 1px solid #90caf9; ',
                  'border-radius: 16px; ',
                  'padding: 6px 14px; ',
                  'margin: 3px; ',
                  'font-size: 12px; ',
                  'cursor: pointer; ',
                  'color: #1565c0; ',
                  'font-weight: 500; ',
                  'transition: all 0.2s ease;',
                  'user-select: none;',
                  '" onmouseover="if(this.style.backgroundColor !== \'rgb(21, 101, 192)\') this.style.backgroundColor=\'#bbdefb\'" ',
                  'onmouseout="if(this.style.backgroundColor !== \'rgb(21, 101, 192)\') this.style.backgroundColor=\'#e3f2fd\'">',
                  v,
                  '</button>'
                )
              }
            )

            # hidden schema divs
            schema_divs <- purrr::map_chr(seq_along(versions), function(i) {
              schema_data <- value$schema[[i]]
              schema_id <- glue("schema_{row_id}_{i - 1}")

              if (is.data.frame(schema_data)) {
                # schema to HTML tbl
                schema_html <- paste0(
                  '<div style="margin-top: 10px; padding: 10px; border: 1px solid #ddd; border-radius: 6px; background-color: #fafafa;">',
                  '<div style="font-weight: 600; margin-bottom: 8px; color: #333;">Version: ',
                  versions[[i]],
                  '</div>',
                  '<div style="font-size: 12px; color: #666; margin-bottom: 10px;">',
                  nrow(schema_data),
                  ' rows × ',
                  ncol(schema_data),
                  ' columns</div>',
                  '<div style="overflow-x: auto; max-height: 300px;">',
                  '<table style="width: 100%; border-collapse: collapse; font-size: 12px;">',
                  '<thead>',
                  paste0(
                    '<th style="border: 1px solid #ddd; padding: 6px; background-color: #f5f5f5; text-align: left;">',
                    names(schema_data),
                    '</th>',
                    collapse = ''
                  ),
                  '</thead>',
                  '<tbody>',
                  paste(
                    apply(schema_data, 1, function(row) {
                      paste0(
                        '<tr>',
                        paste0(
                          '<td style="border: 1px solid #ddd; padding: 6px;">',
                          as.character(row),
                          '</td>',
                          collapse = ''
                        ),
                        '</tr>'
                      )
                    }),
                    collapse = ''
                  ),
                  '</tbody>',
                  '</table>',
                  '</div>',
                  '</div>'
                )
              } else {
                schema_html <- paste0(
                  '<div style="margin-top: 10px; padding: 10px; border: 1px solid #ddd; border-radius: 6px;">',
                  '<div style="font-weight: 600; margin-bottom: 8px;">Version: ',
                  versions[[i]],
                  '</div>',
                  '<div style="color: #999; font-style: italic;">No schema available</div>',
                  '</div>'
                )
              }
              glue('<div id="{schema_id}" style="display: none;">{schema_html}</div>')
            })

            htmltools::HTML(
              paste0(
                '<div>',
                paste(version_buttons, collapse = ''),
                paste(schema_divs, collapse = ''),
                '</div>'
              )
            )
          }
        )
      ),
      ...
    )
  )
}
