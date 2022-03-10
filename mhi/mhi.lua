instrument{
	overlay = true,
	name = 'MHI M1',
	short_name= 'MHI M1',
	icon = '',
}

exibir_doji = input(1, 'Operation display not performed by doji?', input.string_selection, {'Yes', 'Not'})
tipo_mhi = input(1, 'What type of MHI to use?', input.integer, 1, 3, 1) - 1

input_group{
	'Call (Win)',
	call_color = input {default = "GREEN", type = input.color} 
}

input_group{
	'Put (Win)',
	put_color = input {default = "RED", type = input.color}
}

input_group{
	'Loss', loss_color = input{default = "GRAY", type = input.color}
}

input_group{
	'Op. not performed due to doji', 
	doji_color = input{default = 'white', type = input.color}
}

function cores(open, close)

	cor = 'd'
	
	if open > close then
		cor = 'r'
		
	elseif open < close then
		cor = 'g'
		
	end
	
	return cor .. ' '

end

sec = security(current_ticker_id, '5m')

if sec and (sec.open_time == open_time and tipo_mhi == 0) or (open_time == (sec.open_time + (tipo_mhi * 60)) and tipo_mhi > 0) then
	
	velas_cores = cores(open[1 + tipo_mhi], close[1 + tipo_mhi]) .. 
	cores(open[2 + tipo_mhi], close[2 + tipo_mhi]) .. 
	cores(open[3 + tipo_mhi], close[3 + tipo_mhi])
	
	_, count_d = string.gsub(velas_cores, 'd', '')
	
	resultado = open_time - close_time
	
	if count_d == 0 then
	
		_, count_g = string.gsub(velas_cores, 'g', '')
		_, count_r = string.gsub(velas_cores, 'r', '')
		
		plot_shape((count_g > count_r and (open > close)),
			'Put',
			shape_style.triangledown,
			shape_size.large,
			put_color,
			shape_location.belowbar,
			0,
			'Put',
			put_color
		)
		
		plot_shape((count_g < count_r and (open < close )),
			'Call',
			shape_style.triangleup,
			shape_size.large,
			call_color,
			shape_location.abovebar,
			0,
			'Call',
			call_color
		)
		
		plot_shape((count_g < count_r and (open >= close)) or (count_g > count_r and (open <= close)) and resultado <= 1,
			'Loss',
			shape_style.xcross,
			shape_size.large,
			loss_color,
			shape_location.abovebar,
			0,
			'Loss',
			loss_color
		)
		
	else 
	
		if exibir_doji == 1 then
			drop_plot_value('Put', current_bar_id)
			drop_plot_value('Call', current_bar_id)
			drop_plot_value('Loss', current_bar_id)

			plot_shape(1,
			'Doji',
			shape_style.circle,
			shape_size.large,
			doji_color,
			shape_location.abovebar,
			0,
			'Doji',
			doji_color
		)
		
		end
	
	end
	
end

