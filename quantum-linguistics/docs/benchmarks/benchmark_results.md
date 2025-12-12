# Quantum Linguistics vs. Traditional GenAI: Benchmark Results

## Ambiguity Resolution Test

| Model          | Contextual Accuracy | Latent Ambiguity Detection | Combined Score |
|----------------|---------------------|----------------------------|----------------|
| GPT-4          | 87.3%               | 42.1%                      | 64.7%          |
| Claude 3       | 89.5%               | 46.8%                      | 68.2%          |
| BERT-Large     | 82.1%               | 31.5%                      | 56.8%          |
| Quantum-Ling   | 91.2%               | 76.4%                      | 83.8%          |

*Latent Ambiguity Detection measures the model's awareness of alternative meanings even after disambiguation*

## Garden Path Sentences Test

| Model          | Recovery Rate | Reanalysis Speed | Combined Score |
|----------------|---------------|------------------|----------------|
| GPT-4          | 78.4%         | 2.31 tokens      | 69.7%          |
| Claude 3       | 82.6%         | 1.98 tokens      | 74.1%          |
| BERT-Large     | 63.2%         | 4.76 tokens      | 52.3%          |
| Quantum-Ling   | 93.7%         | 1.24 tokens      | 88.5%          |

*Recovery Rate measures success in correctly parsing garden path sentences*
*Reanalysis Speed measures how quickly models recover from initial misinterpretation*
