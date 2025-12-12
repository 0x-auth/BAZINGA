// BAZINGA/src/generators/output/formatTransformer/index.ts
import { exec } from 'child_process';
import path from 'path';
import { Pattern } from '../../../core/patterns';

/**
 * Format transformation options based on pattern DNA
 */
export interface FormatTransformOptions {
    outputType: 'documentation' | 'visualization' | 'implementation' | 'dashboard';
    targetFormat: 'markdown' | 'html' | 'pdf' | 'docx' | 'react' | 'email-html';
    patternDNA?: string; // 5-bit DNA sequence to influence transformation
    enhancementLevel?: number; // Control transformation complexity
}

/**
 * FormatTransformer - Pattern-based document transformation system
 * Aligns with ABSYAMSY DNA patterns:
 * - 10101: Used for expansion/growth in transformation
 * - 11010: Used for convergence/synthesis of formats
 * - 01011: Used for balance/refinement of output
 */
export class FormatTransformer {
    private readonly scriptPath: string;

    constructor() {
        this.scriptPath = path.join(__dirname, 'format-converter.sh');
    }

    /**
     * Transform a document based on pattern DNA
     */
    public async transform(
        inputFile: string,
        outputFile: string,
        options: FormatTransformOptions
    ): Promise<string> {
        // Apply pattern DNA to transformation if provided
        const patternEnhancements = this.applyPatternDNA(options.patternDNA || '10101');

        // Build command with pattern-based enhancements
        let command = `${this.scriptPath}`;

        // Determine input format from file extension
        const inputFormat = this.getFormatFromFileName(inputFile);
        command += ` -f ${inputFormat}`;

        // Map target format to appropriate output format
        const outputFormat = this.mapTargetFormat(options.targetFormat);
        command += ` -t ${outputFormat}`;

        // Apply pattern-specific enhancements
        if (patternEnhancements.standalone) {
            command += ' -s';
        }

        if (patternEnhancements.emailFriendly || options.targetFormat === 'email-html') {
            command += ' -e';
        }

        if (patternEnhancements.prettyFormat) {
            command += ' -p';
        }

        if (patternEnhancements.verbose) {
            command += ' -v';
        }

        // Add enhancement level if specified
        if (options.enhancementLevel && options.enhancementLevel > 0) {
            // Apply additional transformations based on enhancement level
            if (options.enhancementLevel >= 2) {
                // Add CSS for enhanced styling
                const cssPath = path.join(__dirname, 'templates', `${options.outputType}.css`);
                command += ` -c ${cssPath}`;
            }
        }

        command += ` "${inputFile}" "${outputFile}"`;

        // Execute transformation
        return new Promise((resolve, reject) => {
            exec(command, (error, stdout, stderr) => {
                if (error) {
                    reject(new Error(`Format transformation failed: ${stderr || error.message}`));
                    return;
                }

                resolve(stdout);
            });
        });
    }

    /**
     * Apply pattern DNA to determine transformation characteristics
     */
    private applyPatternDNA(patternDNA: string): {
        standalone: boolean;
        emailFriendly: boolean;
        prettyFormat: boolean;
        verbose: boolean;
    } {
        // Default values
        const enhancements = {
            standalone: false,
            emailFriendly: false,
            prettyFormat: false,
            verbose: false
        };

        // Pattern-based enhancements
        if (patternDNA.includes('10101')) { // Divergence/Growth
            enhancements.standalone = true; // Growth requires full document structure
        }

        if (patternDNA.includes('11010')) { // Convergence/Synthesis
            enhancements.prettyFormat = true; // Synthesis requires clean formatting
        }

        if (patternDNA.includes('01011')) { // Balance/Refinement
            enhancements.emailFriendly = true; // Refinement improves compatibility
        }

        if (patternDNA.includes('10111')) { // Recency/Distribution
            enhancements.verbose = true; // Distribution needs detailed output
        }

        return enhancements;
    }

    /**
     * Get format from file name
     */
    private getFormatFromFileName(fileName: string): string {
        const extension = fileName.split('.').pop()?.toLowerCase();

        switch (extension) {
            case 'md':
            case 'markdown':
                return 'markdown';
            case 'html':
            case 'htm':
                return 'html';
            case 'docx':
                return 'docx';
            case 'pdf':
                return 'pdf';
            case 'tex':
                return 'latex';
            case 'rst':
                return 'rst';
            case 'txt':
                return 'plain';
            default:
                return 'markdown'; // Default to markdown if unknown
        }
    }

    /**
     * Map target format to appropriate output format
     */
    private mapTargetFormat(targetFormat: string): string {
        switch (targetFormat) {
            case 'markdown':
                return 'markdown';
            case 'html':
            case 'email-html':
                return 'html';
            case 'pdf':
                return 'pdf';
            case 'docx':
                return 'docx';
            case 'react':
                return 'html'; // Use HTML as intermediate for React transformation
            default:
                return 'html';
        }
    }
}

/**
 * Factory function to create a FormatTransformer instance
 */
export function createFormatTransformer(): FormatTransformer {
    return new FormatTransformer();
}

export default {
    createFormatTransformer
};
