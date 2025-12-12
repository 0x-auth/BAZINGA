// src/core/TypeValidator.ts

import * as ts from 'typescript';
import fs from 'fs';
import path from 'path';
import { ValidationError } from '../utils/errors';

/**
 * TypeValidator - Ensures type safety in generated code
 *
 * This system maintains mathematical purity while ensuring
 * practical type safety in generated artifacts
 */
export class TypeValidator {
    private compiler: typeof ts;
    private compilerOptions: ts.CompilerOptions;

    constructor() {
        this.compiler = ts;
        this.compilerOptions = {
            target: ts.ScriptTarget.ES2020,
            module: ts.ModuleKind.ESNext,
            strict: true,
            esModuleInterop: true,
            skipLibCheck: true,
            forceConsistentCasingInFileNames: true,
            moduleResolution: ts.ModuleResolutionKind.NodeJs,
            declaration: true,
            sourceMap: true
        };
    }

    /**
     * Validate TypeScript code for type safety
     *
     * @param sourceCode The generated TypeScript code
     * @param virtualFilename Virtual filename for the source
     * @returns Validation result with any errors
     */
    public validateCode(sourceCode: string, virtualFilename: string = 'generated.ts'): ValidationResult {
        // Create a virtual compiler host
        const host = this.createCompilerHost(sourceCode, virtualFilename);

        // Create a program
        const program = this.compiler.createProgram(
            [virtualFilename],
            this.compilerOptions,
            host
        );

        // Get semantic diagnostics
        const diagnostics = this.compiler.getPreEmitDiagnostics(program);

        if (diagnostics.length > 0) {
            return {
                valid: false,
                errors: this.formatDiagnostics(diagnostics)
            };
        }

        return {
            valid: true,
            errors: []
        };
    }

    /**
     * Create a virtual compiler host for in-memory validation
     */
    private createCompilerHost(sourceCode: string, virtualFilename: string): ts.CompilerHost {
        const sourceFile = this.compiler.createSourceFile(
            virtualFilename,
            sourceCode,
            this.compilerOptions.target || ts.ScriptTarget.ES2020,
            true
        );

        // Create virtual file system
        const fileMap = new Map<string, ts.SourceFile>();
        fileMap.set(virtualFilename, sourceFile);

        return {
            getSourceFile: (fileName) => {
                // Return virtual source file if it matches
                if (fileName === virtualFilename) {
                    return sourceFile;
                }

                // Try to load from node_modules for lib files
                const libPath = path.join('node_modules', 'typescript', 'lib', fileName);
                if (fs.existsSync(libPath)) {
                    const content = fs.readFileSync(libPath, 'utf8');
                    return this.compiler.createSourceFile(
                        fileName,
                        content,
                        this.compilerOptions.target || ts.ScriptTarget.ES2020
                    );
                }

                return undefined;
            },
            getDefaultLibFileName: () => 'lib.d.ts',
            writeFile: () => {}, // No-op since we're not writing files
            getCurrentDirectory: () => process.cwd(),
            getCanonicalFileName: (fileName) => fileName,
            useCaseSensitiveFileNames: () => true,
            getNewLine: () => '\n',
            fileExists: (fileName) => fileMap.has(fileName) || fs.existsSync(fileName),
            readFile: (fileName) => fileMap.has(fileName)
                ? fileMap.get(fileName)!.text
                : (fs.existsSync(fileName) ? fs.readFileSync(fileName, 'utf8') : undefined)
        };
    }

    /**
     * Format TypeScript diagnostics into readable error messages
     */
    private formatDiagnostics(diagnostics: readonly ts.Diagnostic[]): ValidationError[] {
        return diagnostics.map(diagnostic => {
            const message = this.compiler.flattenDiagnosticMessageText(diagnostic.messageText, '\n');

            // Get location information if available
            let location: { line: number; character: number } | undefined;

            if (diagnostic.file && diagnostic.start !== undefined) {
                const { line, character } = diagnostic.file.getLineAndCharacterOfPosition(diagnostic.start);
                location = { line: line + 1, character: character + 1 };
            }

            return {
                code: diagnostic.code,
                message,
                location,
                severity: this.getSeverity(diagnostic.category)
            };
        });
    }

    /**
     * Map TypeScript diagnostic categories to error severities
     */
    private getSeverity(category: ts.DiagnosticCategory): 'error' | 'warning' | 'info' {
        switch (category) {
            case ts.DiagnosticCategory.Error:
                return 'error';
            case ts.DiagnosticCategory.Warning:
                return 'warning';
            case ts.DiagnosticCategory.Message:
                return 'info';
            default:
                return 'info';
        }
    }
}

/**
 * Pattern type validation - ensures pattern-specific
 * mathematical properties are maintained
 */
export class PatternTypeValidator {
    /**
     * Validate that a particular code snippet adheres to
     * the mathematical constraints of a specific pattern
     */
    public validatePatternConstraints(
        code: string,
        pattern: string
    ): ValidationResult {
        const results: ValidationResult = {
            valid: true,
            errors: []
        };

        // Pattern-specific constraints
        if (pattern.includes('10101')) {
            // Divergence pattern - should include growth operations
            if (!this.containsGrowthOperations(code)) {
                results.valid = false;
                results.errors.push({
                    code: 'PATTERN_CONSTRAINT',
                    message: 'Divergence pattern (10101) requires growth operations',
                    severity: 'error'
                });
            }
        }

        if (pattern.includes('11010')) {
            // Convergence pattern - should include synthesis operations
            if (!this.containsSynthesisOperations(code)) {
                results.valid = false;
                results.errors.push({
                    code: 'PATTERN_CONSTRAINT',
                    message: 'Convergence pattern (11010) requires synthesis operations',
                    severity: 'error'
                });
            }
        }

        if (pattern.includes('01011')) {
            // Balance pattern - should include refinement operations
            if (!this.containsRefinementOperations(code)) {
                results.valid = false;
                results.errors.push({
                    code: 'PATTERN_CONSTRAINT',
                    message: 'Balance pattern (01011) requires refinement operations',
                    severity: 'error'
                });
            }
        }

        return results;
    }

    /**
     * Check if code contains growth operations (required by 10101 pattern)
     * Growth involves: addition, concatenation, array pushing, map extension
     */
    private containsGrowthOperations(code: string): boolean {
        // This is a simplified implementation - would involve AST parsing in production
        const growthPatterns = [
            /\+\+|\+=|\.push\(|\.concat\(|\.add\(|new\s+Map\(|\.set\(/,
            /\[\s*\.\.\./,  // spread operator
            /Object\.assign\(/,
            /\{\s*\.\.\./   // object spread
        ];

        return growthPatterns.some(pattern => pattern.test(code));
    }

    /**
     * Check if code contains synthesis operations (required by 11010 pattern)
     * Synthesis involves: reduction, mapping, filtering, combining
     */
    private containsSynthesisOperations(code: string): boolean {
        // This is a simplified implementation - would involve AST parsing in production
        const synthesisPatterns = [
            /\.reduce\(|\.map\(|\.filter\(|\.flatMap\(/,
            /\.join\(|\.flat\(/,
            /Object\.keys\(|Object\.values\(|Object\.entries\(/,
            /Array\.from\(/
        ];

        return synthesisPatterns.some(pattern => pattern.test(code));
    }

    /**
     * Check if code contains refinement operations (required by 01011 pattern)
     * Refinement involves: validation, error handling, normalization
     */
    private containsRefinementOperations(code: string): boolean {
        // This is a simplified implementation - would involve AST parsing in production
        const refinementPatterns = [
            /if\s*\(|else\s*\{|switch\s*\(/,
            /try\s*\{|catch\s*\(|finally\s*\{/,
            /typeof|instanceof/,
            /\?\s*.*\s*:\s*/,  // ternary operator
            /\.trim\(\)|\.toFixed\(|\.normalize\(/
        ];

        return refinementPatterns.some(pattern => pattern.test(code));
    }
}

/**
 * ValidatorFactory - Creates type and pattern validators
 */
export class ValidatorFactory {
    /**
     * Create TypeScript validator
     */
    public createTypeValidator(): TypeValidator {
        return new TypeValidator();
    }

    /**
     * Create pattern-specific validator
     */
    public createPatternValidator(): PatternTypeValidator {
        return new PatternTypeValidator();
    }

    /**
     * Perform full validation of generated code
     * This combines type checking with pattern-specific validation
     */
    public async validateGenerated(
        code: string,
        pattern: string,
        virtualFilename: string = 'generated.ts'
    ): Promise<ValidationResult> {
        const typeValidator = this.createTypeValidator();
        const patternValidator = this.createPatternValidator();

        // First check type safety
        const typeResults = typeValidator.validateCode(code, virtualFilename);

        // Then check pattern constraints
        const patternResults = patternValidator.validatePatternConstraints(code, pattern);

        // Combine results
        return {
            valid: typeResults.valid && patternResults.valid,
            errors: [...typeResults.errors, ...patternResults.errors]
        };
    }
}

/**
 * Validation result interface
 */
export interface ValidationResult {
    valid: boolean;
    errors: ValidationError[];
}

/**
 * Validation error interface
 */
export interface ValidationError {
    code: string | number;
    message: string;
    location?: { line: number; character: number };
    severity: 'error' | 'warning' | 'info';
}

// Factory function
export function createValidator(): ValidatorFactory {
    return new ValidatorFactory();
}

export default {
    createValidator
};
