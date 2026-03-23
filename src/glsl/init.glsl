void main() {

	const uint id = TDIndex(); 			// Get thread index
	if(id >= TDNumElements()) return;  

	ID[id] = id;						// Store ID
	PosMean[id] = TDIn_P(0, id);		// Copy input position as spawn center 
	Age[id] = -1;						// Trigger immediate rebirth in main loop (age < 0)
}
