const fs = require('fs');
const path = require('path');

const logsDir = path.join(__dirname, '../../logs');

// Ensure logs directory exists
if (!fs.existsSync(logsDir)) {
    fs.mkdirSync(logsDir, { recursive: true });
}

const errorLogFile = path.join(logsDir, 'app-errors.log');
const debugLogFile = path.join(logsDir, 'debug.log');

/**
 * Log error with context information
 * @param {Error} error - The error object
 * @param {Object} context - Additional context (endpoint, user, etc.)
 */
function logError(error, context = {}) {
    const timestamp = new Date().toISOString();
    const logEntry = {
        timestamp,
        error: {
            message: error.message,
            stack: error.stack,
            code: error.code,
            errno: error.errno,
            sql: error.sql,
            sqlState: error.sqlState,
            sqlMessage: error.sqlMessage
        },
        context
    };

    const logLine = JSON.stringify(logEntry, null, 2) + '\n---\n';

    try {
        // Append to log file
        fs.appendFileSync(errorLogFile, logLine);
    } catch (fileError) {
        console.error('Failed to write to log file:', fileError);
    }

    // Also log to console
    console.error(`[${timestamp}] ERROR:`, error.message);
    if (context.endpoint) console.error('Endpoint:', context.endpoint);
    if (context.userId) console.error('User:', context.userId);
    if (context.shopId) console.error('Shop:', context.shopId);
}

/**
 * Log debug information
 * @param {string} message - Debug message
 * @param {Object} data - Additional data to log
 */
function logDebug(message, data = {}) {
    const timestamp = new Date().toISOString();
    const logEntry = {
        timestamp,
        message,
        data
    };

    const logLine = JSON.stringify(logEntry) + '\n';

    try {
        fs.appendFileSync(debugLogFile, logLine);
    } catch (fileError) {
        console.error('Failed to write to debug log:', fileError);
    }

    if (process.env.NODE_ENV === 'development') {
        console.log(`[${timestamp}] DEBUG:`, message, data);
    }
}

/**
 * Log HTTP request details
 * @param {Object} req - Express request object
 * @param {string} label - Label for this log entry
 */
function logRequest(req, label = 'REQUEST') {
    logDebug(label, {
        method: req.method,
        url: req.url,
        params: req.params,
        query: req.query,
        body: req.body,
        user: req.user?.id,
        shop: req.shopId
    });
}

module.exports = {
    logError,
    logDebug,
    logRequest
};
