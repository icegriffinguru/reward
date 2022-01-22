const { ethers } = require("hardhat");

const pow = ethers.BigNumber.from(10).pow(18);

function convertFromBigNumber(bigNumber) {
	let str = "";

	const bigNumberStr = bigNumber.toString();
	if (bigNumberStr.length < 19) {
		str += "0.";
		for (let i = bigNumberStr.length; i < 18; i++) {
			str += "0";
		}
	}
	for (let i = 0; i < bigNumberStr.length; i++) {
		str += bigNumberStr[i];
		if (bigNumberStr.length - i - 1 == 18) {
			str += ".";
		}
	}
	return parseFloat(str);
}

function convertToBigNumber(number) {
	if (typeof number === "string")
		number = parseFloat(number);
	if (Number.isInteger(number))
		return pow.mul(number);
	let bigNumber = pow.mul(Math.floor(number));
	number -= Math.floor(number);
	let decimalNb = 0;
	while (!Number.isInteger(number)) {
		number *= 10;
		decimalNb++;
	}
	bigNumberDecimal = ethers.BigNumber.from(number.toString());
	bigNumberDecimal = bigNumberDecimal.mul(ethers.BigNumber.from(10).pow(18 - decimalNb));
	return bigNumber.add(bigNumberDecimal);
}


module.exports = {
	convertFromBigNumber,
	convertToBigNumber,
}
