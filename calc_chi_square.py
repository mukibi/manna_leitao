import scipy.stats

with open("friday_observed_expected.csv", "r") as friday_data:

	for line in friday_data:

		data_line = line.rstrip()
		data_bts = data_line.split(",")

		expected_values = [float(data_bts[1])] * 5
		observed_values = [int(x) for x in data_bts[2:]]


		result = scipy.stats.chisquare(observed_values, f_exp=expected_values)
		print(data_bts[0], "\t", "{:.6f}".format(result[1]))

		#print(expected_values, observed_values)


