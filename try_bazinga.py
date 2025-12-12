from src.core.bazinga import BazingaUniversalTool

# Create the tool
bazinga = BazingaUniversalTool()

# Example 1: Encode a concept
encoded = bazinga.encode(3, 2, [2, 1, 5, 3, 2])
print(f"\nExample 1: Encoding a concept")
print(f"Encoded: {encoded}")
print(f"Explanation: {bazinga.explain(encoded)}")

# Example 2: Generate a Fibonacci sequence
fibonacci = bazinga.generate_fibonacci(8)
print(f"\nExample 2: Generating a Fibonacci sequence")
print(f"Sequence: {fibonacci}")
print(f"Explanation: {bazinga.explain(fibonacci)}")

# Example 3: Create a conversation encoding
concepts = [
    {"section": 1, "subsection": 2, "attributes": [3, 4, 5]},
    {"section": 4, "subsection": 1, "attributes": [1, 3, 5, 2, 4]}
]
print(f"\nExample 3: Creating conversation encodings")
conversation = bazinga.create_conversation_encoding(concepts)
for seq in conversation:
    print(f"  {seq}: {bazinga.explain(seq)}")
