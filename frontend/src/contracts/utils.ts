export const calculateTimeInterval = (timeUnit: number, timeRange: string) => {
    timeRange = timeRange.toUpperCase()
    let interval;

    switch (timeRange) {
        case 'HOURS':
            interval = timeUnit * 3600
            break;
        case 'DAYS':
            interval = timeUnit * 3600 * 24
            break;
        case 'WEEKS':
            interval = timeUnit * 3600 * 24 * 7
            break;
        case 'MONTHS':
            interval = timeUnit * 3600 * 24 * 30
            break;
        default:
            break
    }
    return interval
}