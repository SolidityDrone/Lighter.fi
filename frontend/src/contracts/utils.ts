export const calculateTimeInterval = (timeUnit: number, timeRange: string) => {
    if (timeRange) {
        let interval;

        switch (timeRange) {
            case 'Hours':
                interval = timeUnit * 3600
                break;
            case 'Days':
                interval = timeUnit * 3600 * 24
                break;
            case 'Weeks':
                interval = timeUnit * 3600 * 24 * 7
                break;
            case 'Months':
                interval = timeUnit * 3600 * 24 * 30
                break;
            default:
                break
        }
        return interval
    }
    return ""
}