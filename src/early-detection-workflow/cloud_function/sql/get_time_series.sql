SELECT {time_column}, {value_column} 
FROM `{view_name}` 
WHERE {time_column} BETWEEN TIMESTAMP('{start_time}') AND TIMESTAMP('{end_time}')
ORDER BY {time_column}
