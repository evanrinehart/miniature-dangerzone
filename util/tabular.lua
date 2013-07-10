-- produce a "pref" preformatted data set suitable for tell_pref
-- give it an array of arrays of cells, where each cell is like
-- cols is an array of 
-- {
--   align='right',
--   divider='|',
--   width=10
-- }
--
-- rows is an array of arrays of
-- {
--   text="abc",
--   color="yellow"
-- }
-- a row may also contain "divider" by itself to produce a divider

function tabular(rows, cols)
  local col_count = #cols
  local total_width = 0
  local col_fmts = {}

  for i, col in ipairs(cols) do
    total_width = total_width + col.width
    if col.divider then
      total_width = total_width + #col.divider
    end

    if col.align == 'left' then
      col_fmts[i] = "%"..-col.width.."s"
    else
      col_fmts[i] = "%"..col.width.."s"
    end
  end

  local buf = {}

  for i, row in ipairs(rows) do
    if row == 'divider' then
      table.insert(buf, {{text=string.rep('-', total_width)}})
    else
      local rbuf = {}
      for j = 1, col_count do
        local text = row[j].text
        local trunc_text = text
        if #trunc_text > cols[j].width then
          trunc_text = string.sub(trunc_text, 1, cols[j].width)
        end
        local padded_text = string.format(col_fmts[j], trunc_text)
        if cols[j].divider then
          table.insert(rbuf, {text=cols[j].divider})
        end
        table.insert(
          rbuf,
          {
            text = padded_text,
            color = row[j].color,
            bold = row[j].bold
          }
        )
      end
      table.insert(buf, rbuf)
    end
  end

  return buf
end
