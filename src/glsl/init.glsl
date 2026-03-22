void main() {
	const uint id = TDIndex();
	if(id >= TDNumElements())
		return;

	ID[id] = id;
	PosMean[id] = TDIn_P(0, id);
	Age[id] = -1;
}
